import Foundation
import GCP_Remote
import Logger
import TSCBasic

struct DependenciesDownloadError: Error {
    let message: String
}

struct DownloadableDependency {
    let name: String
    let version: String
}

protocol DependenciesDownloading {
    func downloadDependencies(dependencies: [DownloadableDependency]) async throws
}

struct LocalDependenciesDownloader: DependenciesDownloading {
    private let archiveService: ArchiveServicing
    private let fileSystem: FileSystem
    private let gcpDownloader: GCPDownloading?
    private let pathProvider: PathProviding
    private let logger: Logging
    
    // MARK: - Initializers
    
    init(
        archiveService: ArchiveServicing = ZipService(system: System.shared),
        fileSystem: FileSystem = localFileSystem,
        gcpDownloader: GCPDownloading?,
        logger: Logging = Logger.shared,
        pathProvider: PathProviding
    ) {
        self.archiveService = archiveService
        self.fileSystem = fileSystem
        self.gcpDownloader = gcpDownloader
        self.logger = logger
        self.pathProvider = pathProvider
    }
    
    // MARK: - Interface
    
    func downloadDependencies(dependencies: [DownloadableDependency]) async throws {
        let buildDir = pathProvider.buildDir()
        let missingDependencies = missingLocalDependencies(dependencies)
        
        if missingDependencies.isEmpty {
            logger.info("All dependencies are available in local cache")
        } else {
            try? await downloadMissingDependencies(missingDependencies)
        }
        
        try? fileSystem.createDirectory(buildDir, recursive: true)
        
        dependencies.forEach { dependency in
            let cachePath = pathProvider.cacheDir(
                dependency: dependency.name,
                version: dependency.version
            )
            
            guard fileSystem.exists(cachePath) else { return }
            
            do {
                try archiveService.unarchive(
                    from: cachePath,
                    destination: buildDir
                )
            } catch {
                logger.error("Unable to extract cached dependency", dependency.name, dependency.version)
            }
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
    
    private func downloadMissingDependencies(_ missingDependencies: [DownloadableDependency]) async throws {
        guard let gcpDownloader = gcpDownloader else {
            return
        }
        
        let downloadItems = missingDependencies.map { dependency in
            DownloadItem(
                remotePath: pathProvider.remoteCachePath(dependency: dependency.name, version: dependency.version),
                localFile: pathProvider.cacheDir(dependency: dependency.name, version: dependency.version)
            )
        }
        
        try await gcpDownloader.download(items: downloadItems)
    }
}
