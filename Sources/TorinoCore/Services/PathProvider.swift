import Foundation
import TSCBasic

public protocol PathProviding {
    /// Directory where built xcframeworks should be placed
    ///
    ///  E.g. for Carthage `Carthage/Build`
    func buildDir() -> AbsolutePath

    /// Root directory where Torino cache is stored
    func cacheDir() -> AbsolutePath
    
    /// Directory where Torino cache is stored
    func cacheDir(dependency: String, version: String) -> AbsolutePath
    
    /// Path to Cartfile.resolved
    func lockfile() -> AbsolutePath
    
    func remoteCachePath(dependency: String, version: String) -> String
}

struct PathProviderError: Error {
    let message: String
}

struct CarthagePathProvider: PathProviding {
    private let base: AbsolutePath
    private let _cacheDir: AbsolutePath
    private let prefix: String
    
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
        self.prefix = prefix
    }
    
    func buildDir() -> AbsolutePath {
        base.appending(components: "Carthage", "Build")
    }

    func cacheDir() -> AbsolutePath {
        _cacheDir
    }
    
    func cacheDir(dependency: String, version: String) -> AbsolutePath {
        _cacheDir.appending(component: dependency + "-" + version + ".zip")
    }
    
    func lockfile() -> AbsolutePath {
        base.appending(components: "Cartfile.resolved")
    }
    
    func remoteCachePath(dependency: String, version: String) -> String {
        [
            prefix,
            cacheDir(dependency: dependency, version: version).basename
        ].filter { $0.count > 0 }
        .joined(separator: "/")
    }
}
