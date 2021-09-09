import Foundation
import TSCBasic

struct DependenciesUploadError: Error {
    let message: String
}

protocol DependenciesUploading {
    func uploadDependencies(_ dependencies: [Dependency], prefix: String) throws
}

struct LocalDependenciesUploader: DependenciesUploading {
    private let fileSystem: FileSystem
    
    // MARK: - Initializers
    
    init(fileSystem: FileSystem = localFileSystem) {
        self.fileSystem = fileSystem
    }
    
    func uploadDependencies(_ dependencies: [Dependency], prefix: String) throws {
        guard let cacheDir = fileSystem.cachesDirectory else {
            throw DependenciesUploadError(message: "Unable to get caching directory")
        }
        
        let torinoDir = cacheDir.appending(components: "Torino", prefix)
        
        if fileSystem.isFile(torinoDir) {
            try fileSystem.removeFileTree(torinoDir)
        }
        
        try? fileSystem.createDirectory(torinoDir, recursive: true)
        
        try dependencies.forEach { dependency in
            let dependencyDir = torinoDir.appending(components: dependency.name, dependency.version)
        
            try? fileSystem.createDirectory(dependencyDir, recursive: true)
            
            try dependency.frameworks.forEach { container in
                let destination = dependencyDir.appending(component: container.name)
                
                try? fileSystem.removeFileTree(destination)
                try fileSystem.copy(from: container.path, to: destination)
            }
        }
    }
}
