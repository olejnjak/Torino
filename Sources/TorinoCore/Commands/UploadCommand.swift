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
        }.flatMap(.latest) { resolvedCartfile, swiftVersion -> SignalProducer<Void, TorinoError> in
            /// Load version file for each dependency
            let versionFiles = resolvedCartfile.dependencies.keys.map { dependency -> (Dependency, VersionFile?) in
                let versionFileURL = VersionFile.url(for: dependency, rootDirectoryURL: project.directoryURL)
                let versionFile = VersionFile(url: versionFileURL)
                return (dependency, versionFile)
            }
            
            /// Check that that all dependencies match with its version file
            let mismatchedDependencies = versionFiles.map { dependency, versionFile -> SignalProducer<Void, TorinoError> in
                guard let versionFile = versionFile, let version = resolvedCartfile.dependencies[dependency] else {
                    let mismatch = DependencyMismatch(dependency: dependency, resolvedVersion: resolvedCartfile.dependencies[dependency], versionFileCommitish: nil)
                    return SignalProducer(error: TorinoError.versionFileMismatch([mismatch]))
                }
                
                let allPlatformsMatch = platforms.map { versionFile.satisfies(platform: $0,
                                                                              commitish: version.commitish,
                                                                              binariesDirectoryURL: project.rootBinariesURL,
                                                                              localSwiftVersion: swiftVersion) }
                return SignalProducer(allPlatformsMatch).flatten(.merge)
                    .mapError(TorinoError.init)
                    .collect()
                    .map { x -> Bool in x.reduce(true) { $0 && $1 } }
                    .attemptMap { $0 ? .success(()) : .failure(TorinoError.versionFileMismatch([DependencyMismatch(dependency: dependency, resolvedVersion: version, versionFileCommitish: versionFile.commitish)])) }
            }
            
            return SignalProducer(mismatchedDependencies).flatten(.concat)
            //                return versionCheck.flatMap(.latest) { versionCheck -> SignalProducer<Void, TorinoError> in
            //                    /// List of dependencies that have mismatched versions
            //                    let mismatchedDependencies = versionCheck.compactMap { dependency, match in
            //                        match ? nil : dependency
            //                    }
            //                    return .empty
            //
            ////                    mismatchedDependencies.isEmpty ? uploader.upload(resolvedCartfile, from: project) : SignalProducer
            ////                    versionsMatch ?  : SignalProducer(error: .versionFileMismatch)
            //                }
        }.wait()
        
        print("[RESULT]", result)
    }
}
