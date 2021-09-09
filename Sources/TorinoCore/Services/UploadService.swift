import Foundation
import TSCBasic

final class UploadService {
    private let dependenciesLoader: DependenciesLoading
    
    // MARK: - Initializers
    
    init(
        dependenciesLoader: DependenciesLoading = CarthageDependenciesLoader()
    ) {
        self.dependenciesLoader = dependenciesLoader
    }
    
    func run(path: AbsolutePath) throws {
        let dependencies = try dependenciesLoader.loadDependencies(at: path)
        print("[DEPENDENCIES]", dependencies.flatMap(\.frameworks).map(\.name))
    }
}
