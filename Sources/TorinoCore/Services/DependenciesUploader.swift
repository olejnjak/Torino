import Foundation
import TSCBasic

struct DependenciesUploadError: Error {
    let message: String
}

protocol DependenciesUploading {
    func uploadDependencies(_ dependencies: [Dependency]) throws
}

struct LocalDependenciesUploader: DependenciesUploading {
    private let archiveService: ArchiveServicing
    private let fileSystem: FileSystem
    private let pathProvider: PathProviding
    
    // MARK: - Initializers
    
    init(
        artchiveService: ArchiveServicing = ZipService(),
        fileSystem: FileSystem = localFileSystem,
        pathProvider: PathProviding
    ) {
        self.archiveService = artchiveService
        self.fileSystem = fileSystem
        self.pathProvider = pathProvider
    }
    
    func uploadDependencies(_ dependencies: [Dependency]) throws {
        let buildDir = pathProvider.buildDir()
        
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
        }
    }
}
