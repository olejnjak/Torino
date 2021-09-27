import Foundation
import TSCBasic

struct DependenciesDownloadError: Error {
    let message: String
}

struct DownloadableDependency {
    let name: String
    let version: String
}

protocol DependenciesDownloading {
    func downloadDependencies(dependencies: [DownloadableDependency]) throws
}

struct LocalDependenciesDownloader: DependenciesDownloading {
    private let fileSystem: FileSystem
    private let pathProvider: PathProviding
    
    // MARK: - Initializers
    
    init(
        fileSystem: FileSystem = localFileSystem,
        pathProvider: PathProviding
    ) {
        self.fileSystem = fileSystem
        self.pathProvider = pathProvider
    }
    
    func downloadDependencies(dependencies: [DownloadableDependency]) throws {
        let buildDir = pathProvider.buildDir()
        
        try? fileSystem.createDirectory(buildDir, recursive: true)
        
        try dependencies.forEach { dependency in
            let cacheDir = pathProvider.cacheDir(
                dependency: dependency.name,
                version: dependency.version
            )
            
            let cachedFiles = try fileSystem.getDirectoryContents(cacheDir)
            
            cachedFiles.forEach { path in
                let destination = buildDir.appending(component: path)
                let cached = cacheDir.appending(component: path)
                
                try? fileSystem.copy(from: cached, to: destination)
            }
        }
    }
}
