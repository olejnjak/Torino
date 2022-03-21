import Foundation
import GCP_Remote
import TSCBasic

struct DependenciesUploadError: Error {
    let message: String
}

protocol DependenciesUploading {
    func uploadDependencies(_ dependencies: [Dependency]) async throws
}

struct LocalDependenciesUploader: DependenciesUploading {
    private let archiveService: ArchiveServicing
    private let fileSystem: FileSystem
    private let pathProvider: PathProviding
    private let gcpUploader: GCPUploading?
    
    // MARK: - Initializers
    
    init(
        archiveService: ArchiveServicing = ZipService(system: System.shared),
        fileSystem: FileSystem = localFileSystem,
        pathProvider: PathProviding,
        gcpUploader: GCPUploading?
    ) {
        self.archiveService = archiveService
        self.fileSystem = fileSystem
        self.pathProvider = pathProvider
        self.gcpUploader = gcpUploader
    }
    
    func uploadDependencies(_ dependencies: [Dependency]) async throws {
        let buildDir = pathProvider.buildDir()
        var uploadItems = [UploadItem]()
        
        try dependencies.forEach { dependency in
            let cachePath = pathProvider.cacheDir(
                dependency: dependency.name,
                version: dependency.version
            )
        
            try? fileSystem.createDirectory(cachePath.parentDirectory, recursive: true)
        
            let paths = dependency.frameworks.map { $0.path.relative(to: buildDir) }
            
            try archiveService.archive(
                files: paths + [dependency.versionFile.relative(to: buildDir)],
                basePath: buildDir,
                destination: cachePath
            )
            
            uploadItems.append(.init(
                localFile: cachePath,
                remotePath: pathProvider.remoteCachePath(
                    dependency: dependency.name,
                    version: dependency.version
                ),
                hash: "" // TODO: Implement
            ))
        }
        
        if let gcpUploader = gcpUploader {
            try await gcpUploader.upload(items: uploadItems)
        }
    }
}
