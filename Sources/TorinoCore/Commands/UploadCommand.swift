import CarthageKit
import Foundation
import ReactiveSwift
import Result
import TSCUtility
import XCDBLD

internal struct UploadCommand: Command {
    static var name: String { "upload" }
    
    private let uploader: DependencyUploading
    
    // MARK: - Initializers
    
    public init(parser: ArgumentParser) {
        self.init(parser: parser, uploader: DependencyUploader())
    }
    
    public init(parser: ArgumentParser, uploader: DependencyUploading) {
        self.uploader = uploader
        
        // Subparser will be used later
        _ = parser.add(subparser: "upload", overview: "Uploads dependencies to shared storage")
    }
    
    // MARK: - Public interface
    
    func run(with arguments: ArgumentParser.Result) throws {
        let fm = FileManager.default
        let pwd = URL(fileURLWithPath: fm.currentDirectoryPath)
        let project = Project(directoryURL: pwd)
        let platforms = Set([XCDBLD.Platform.iOS])
        let uploader = self.uploader
        let toolchain: String? = nil
        
        let result = project.loadResolvedCartfile().mapError(TorinoError.init)
            .flatMap(.latest) { resolvedCartfile -> SignalProducer<(cartfile: ResolvedCartfile, swiftVersion: String), TorinoError> in
                swiftVersion(usingToolchain: toolchain).map { (resolvedCartfile, $0) }
                    .mapError { CarthageError.internalError(description: $0.description) }
                    .mapError(TorinoError.init)
        }.flatMap(.latest) { resolvedCartfile, swiftVersion -> SignalProducer<ResolvedCartfile, TorinoError> in
            /// Load version file for each dependency
            let versionFiles = resolvedCartfile.dependencies.keys.map { dependency -> (Dependency, VersionFile?) in
                let versionFileURL = VersionFile.url(for: dependency, rootDirectoryURL: project.directoryURL)
                let versionFile = VersionFile(url: versionFileURL)
                return (dependency, versionFile)
            }
            
            /// Check that that all dependencies match with its version file
            let mismatchedDependencies = versionFiles.map { dependency, versionFile -> SignalProducer<DependencyMismatch?, TorinoError> in
                guard let versionFile = versionFile, let version = resolvedCartfile.dependencies[dependency] else {
                    let mismatch = DependencyMismatch(dependency: dependency, resolvedVersion: resolvedCartfile.dependencies[dependency], versionFileCommitish: nil)
                    return SignalProducer(value: mismatch)
                }
                
                let allPlatformsMatch = platforms.map { versionFile.satisfies(platform: $0,
                                                                              commitish: version.commitish,
                                                                              binariesDirectoryURL: project.rootBinariesURL,
                                                                              localSwiftVersion: swiftVersion) }
                return SignalProducer(allPlatformsMatch).flatten(.concat)
                    .mapError(TorinoError.init)
                    .collect()
                    .map { $0.contains(false) }
                    .map { $0 ? DependencyMismatch(dependency: dependency, resolvedVersion: version, versionFileCommitish: versionFile.commitish) : nil }
            }
            
            return SignalProducer(mismatchedDependencies).flatten(.concat)
                .collect()
                .map { $0.compactMap { $0 } }
                .attemptMap { $0.isEmpty ? .success(resolvedCartfile) : .failure(TorinoError.versionFileMismatch($0)) }
        }
        .flatMap(.latest) { uploader.upload($0, platforms: [.iOS], from: project) }
        .wait()
        
        print("[RESULT]", result)
    }
}
