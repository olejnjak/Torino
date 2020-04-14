import CarthageKit
import Foundation
import ReactiveSwift
import XCDBLD

/// Protocol wrapping dependecy upload service
public protocol DependencyUploading {
    /// Upload given `dependencies` from `project` to cache
    func upload(_ dependencies: [Dependency: PinnedVersion], platforms: [Platform], from project: Project) -> SignalProducer<Void, TorinoError>
}

public extension DependencyUploading {
    /// Upload all dependencies from given `cartfile` and `project` to cache
    func upload(_ cartfile: ResolvedCartfile, platforms: [Platform], from project: Project) -> SignalProducer<Void, TorinoError> {
        upload(cartfile.dependencies, platforms: platforms, from: project)
    }
}

public final class DependencyUploader: DependencyUploading {
    private let pathResolver: CachePathResolving
    
    // MARK: - Initializers
    
    public convenience init() {
        self.init(cachePathResolver: CachePathResolver())
    }
    
    internal init(cachePathResolver: CachePathResolving) {
        self.pathResolver = cachePathResolver
    }
    
    // MARK: - Public interface
    
    public func upload(_ dependencies: [Dependency : PinnedVersion], platforms: [Platform], from project: Project) -> SignalProducer<Void, TorinoError> {
        let pathResolver = self.pathResolver
        let platforms = platforms.isEmpty ? Platform.supportedPlatforms : platforms
        
        return swiftPrefix().flatMap(.latest) { [weak self] swiftVersion -> SignalProducer<Void, TorinoError> in
                guard let self = self else { return .empty }
                let dependencyProducers = dependencies.map { dependency, version -> [SignalProducer<Void, TorinoError>] in
                    let mappedDependencies = RepositoryMap.shared.frameworkNames(for: dependency)
                    
                    return mappedDependencies.map { mappedDependency in
                        platforms.map { self.upload(pathResolver.frameworkPath(for: mappedDependency, platform: $0, in: project), to: pathResolver.path(for: dependency.name, version: version, swiftVersion: swiftVersion) + "/" +  mappedDependency + ".framework")
                        }
                    }.flatMap { $0 }
                }
                
                return SignalProducer(dependencyProducers.flatMap { $0 })
                    .flatten(.concat)
        }
    }
    
    // MARK: - Private helpers
    
    private func upload(_ framework: String, to path: String) -> SignalProducer<Void, TorinoError> {
        SignalProducer { observer, _ in
            do {
                let destination = "/Users/olejnjak/Desktop/Cache/" + path
                let destinationDir = (destination as NSString).deletingLastPathComponent
                
                try FileManager.default.createDirectory(atPath: destinationDir, withIntermediateDirectories: true)
                try? FileManager.default.removeItem(atPath: destination)
                try FileManager.default.copyItem(atPath: framework, toPath: destination)
                observer.send(value: ())
                observer.sendCompleted()
            } catch {
                observer.send(error: TorinoError.unknown(description: error.localizedDescription))
            }
        }
    }
}

func swiftPrefix() -> SignalProducer<String, TorinoError> {
    swiftVersion().mapError(TorinoError.init)
        .map { "Swift-" + $0.components(separatedBy: " ")[0] }
}
