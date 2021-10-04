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
    private let archiveService: ArchiveServicing
    private let fileSystem: FileSystem
    private let pathProvider: PathProviding
    
    // MARK: - Initializers
    
    init(
        archiveService: ArchiveServicing = ZipService(),
        fileSystem: FileSystem = localFileSystem,
        pathProvider: PathProviding
    ) {
        self.archiveService = archiveService
        self.fileSystem = fileSystem
        self.pathProvider = pathProvider
    }
    
    func downloadDependencies(dependencies: [DownloadableDependency]) throws {
        let buildDir = pathProvider.buildDir()
        
        try? fileSystem.createDirectory(buildDir, recursive: true)
        
        try dependencies.forEach { dependency in
            let cachePath = pathProvider.cacheDir(
                dependency: dependency.name,
                version: dependency.version
            )
            
            guard fileSystem.exists(cachePath) else { return }
            
            try archiveService.unarchive(
                from: cachePath,
                destination: buildDir
            )
        }
    }
}
