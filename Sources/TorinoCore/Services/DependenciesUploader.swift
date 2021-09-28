import Foundation
import TSCBasic

struct DependenciesUploadError: Error {
    let message: String
}

protocol DependenciesUploading {
    func uploadDependencies(_ dependencies: [Dependency]) throws
}

struct LocalDependenciesUploader: DependenciesUploading {
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
    
    func uploadDependencies(_ dependencies: [Dependency]) throws {
        try dependencies.forEach { dependency in
            let dependencyDir = pathProvider.cacheDir(
                dependency: dependency.name,
                version: dependency.version
            )
        
            try? fileSystem.removeFileTree(dependencyDir)
            try fileSystem.createDirectory(dependencyDir, recursive: true)
            
            try dependency.frameworks.forEach { container in
                let destination = dependencyDir.appending(component: container.name)
                
                try? fileSystem.removeFileTree(destination)
                try fileSystem.copy(from: container.path, to: destination)
            }
            
            try fileSystem.copy(
                from: dependency.versionFile,
                to: dependencyDir.appending(component: dependency.versionFile.basename)
            )
        }
    }
}
