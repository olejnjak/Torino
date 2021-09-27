import Foundation
import TSCBasic

public protocol PathProviding {
    /// Directory where built xcframeworks should be placed
    ///
    ///  E.g. for Carthage `Carthage/Build`
    func buildDir() -> AbsolutePath
    
    /// Directory where Torino cache is stored
    func cacheDir(dependency: String, version: String) -> AbsolutePath
    
    /// Path to Cartfile.resolved
    func lockfile() -> AbsolutePath
}

struct PathProviderError: Error {
    let message: String
}

struct CarthagePathProvider: PathProviding {
    private let base: AbsolutePath
    private let _cacheDir: AbsolutePath
    
    // MARK: - Initializers
    
    init(
        fileSystem: FileSystem = localFileSystem,
        base: AbsolutePath,
        prefix: String
    ) throws {
        guard let cachesDirectory = fileSystem.cachesDirectory else {
            throw PathProviderError(message: "Unable to get caches directory")
        }
        
        _cacheDir = cachesDirectory.appending(components: "Torino", prefix)
        self.base = base
    }
    
    func buildDir() -> AbsolutePath {
        base.appending(components: "Carthage", "Build")
    }
    
    func cacheDir(dependency: String, version: String) -> AbsolutePath {
        _cacheDir.appending(components: dependency, version)
    }
    
    func lockfile() -> AbsolutePath {
        base.appending(components: "Cartfile.resolved")
    }
}
