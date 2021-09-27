import Foundation
import TSCBasic

final class UploadService {
    private let dependenciesLoader: DependenciesLoading
    private let dependenciesUploader: DependenciesUploading
    
    // MARK: - Initializers
    
    init(
        dependenciesLoader: DependenciesLoading,
        dependenciesUploader: DependenciesUploading
    ) {
        self.dependenciesLoader = dependenciesLoader
        self.dependenciesUploader = dependenciesUploader
    }
    
    func run(path: AbsolutePath) throws {
        let dependencies = try dependenciesLoader.loadDependencies(at: path)
        
        try dependenciesUploader.uploadDependencies(dependencies, prefix: "Swift-5.5")
    }
}