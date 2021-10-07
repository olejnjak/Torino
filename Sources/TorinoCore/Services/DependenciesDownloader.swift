import Foundation
import TSCBasic
import GCP_Remote

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
    private let gcpDownloader: GCPDownloading
    private let pathProvider: PathProviding
    
    // MARK: - Initializers
    
    init(
        archiveService: ArchiveServicing = ZipService(),
        fileSystem: FileSystem = localFileSystem,
        gcpDownloader: GCPDownloading = GCPDownloader(),
        pathProvider: PathProviding
    ) {
        self.archiveService = archiveService
        self.fileSystem = fileSystem
        self.gcpDownloader = gcpDownloader
        self.pathProvider = pathProvider
    }
    
    // MARK: - Interface
    
    func downloadDependencies(dependencies: [DownloadableDependency]) throws {
        let buildDir = pathProvider.buildDir()
        let missingDependencies = missingLocalDependencies(dependencies)
        
        try? downloadMissingDependencies(missingDependencies)
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
    
    // MARK: - Private helpers
    
    private func missingLocalDependencies(_ requestedDependencies: [DownloadableDependency]) -> [DownloadableDependency] {
        requestedDependencies.filter { dependency in
            let cachePath = pathProvider.cacheDir(
                dependency: dependency.name,
                version: dependency.version
            )
            
            return !fileSystem.exists(cachePath)
        }
    }
    
    private func downloadMissingDependencies(_ missingDependencies: [DownloadableDependency]) throws {
        let downloadItems = missingDependencies.map { dependency in
            DownloadItem(
                remotePath: pathProvider.remoteCachePath(dependency: dependency.name, version: dependency.version),
                localFile: pathProvider.cacheDir(dependency: dependency.name, version: dependency.version)
            )
        }
        
        try gcpDownloader.download(items: downloadItems)
    }
}
