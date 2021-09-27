import Foundation
import TSCBasic

public struct DependenciesLoadingError: Error {
    public let message: String
}

public protocol DependenciesLoading {
    func loadDependencies(at path: AbsolutePath) throws -> [Dependency]
}

public struct CarthageDependenciesLoader: DependenciesLoading {
    private let fileSystem: FileSystem
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - Initializers
    
    public init(fileSystem: FileSystem = localFileSystem) {
        self.fileSystem = fileSystem
    }
    
    public func loadDependencies(at path: AbsolutePath) throws -> [Dependency] {
        let carthageBuildDir = path.appending(components: "Carthage", "Build")
        
        guard fileSystem.exists(carthageBuildDir) else {
            throw DependenciesLoadingError(message: "Carthage/Build directory doesn't exist at \(path)")
        }
        
        guard fileSystem.isDirectory(carthageBuildDir) else {
            throw DependenciesLoadingError(message: "Carthage/Build is not a directory at \(path)")
        }
        
        let isVersionFile: (String) -> Bool = { $0.hasPrefix(".") && $0.hasSuffix(".version") }
        let versionFiles = try fileSystem.getDirectoryContents(carthageBuildDir)
            .filter(isVersionFile)
            .map { carthageBuildDir.appending(component: $0) }
            .map { VersionFilePath(path: $0) }
            .map { versionFilePath -> VersionFileWithName in
                let bytes = try fileSystem.readFileContents(versionFilePath.path)
                let data = Data(bytes.contents)
                return VersionFileWithName(
                    name: versionFilePath.name,
                    versionFile: try jsonDecoder.decode(VersionFile.self, from: data),
                    path: versionFilePath.path
                )
            }
        
        return versionFiles.map {
            Dependency(
                name: $0.name,
                version: $0.versionFile.commitish,
                frameworks: $0.versionFile.allContainers.map {
                    .init(name: $0, path: carthageBuildDir.appending(component: $0))
                },
                versionFile: $0.path
            )
        }
    }
}
