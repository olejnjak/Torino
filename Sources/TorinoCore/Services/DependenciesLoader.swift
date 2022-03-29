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
    private let pathProvider: PathProviding
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - Initializers
    
    public init(
        fileSystem: FileSystem = localFileSystem,
        pathProvider: PathProviding
    ) {
        self.fileSystem = fileSystem
        self.pathProvider = pathProvider
    }
    
    public func loadDependencies(at path: AbsolutePath) throws -> [Dependency] {
        let buildDir = pathProvider.buildDir()
        
        guard fileSystem.exists(buildDir) else {
            throw DependenciesLoadingError(message: "Carthage/Build directory doesn't exist at \(path)")
        }
        
        guard fileSystem.isDirectory(buildDir) else {
            throw DependenciesLoadingError(message: "Carthage/Build is not a directory at \(path)")
        }
        
        let isVersionFile: (String) -> Bool = { $0.hasPrefix(".") && $0.hasSuffix(".version") }
        let versionFiles = try fileSystem.getDirectoryContents(buildDir)
            .filter(isVersionFile)
            .map { buildDir.appending(component: $0) }
            .map { VersionFilePath(path: $0) }
            .map { versionFilePath -> VersionFileWithName in
                let bytes = try fileSystem.readFileContents(versionFilePath.path)
                let data = Data(bytes.contents)
                return VersionFileWithName(
                    name: versionFilePath.name,
                    versionFile: try jsonDecoder.decode(VersionFile.self, from: data),
                    path: versionFilePath.path
                )
            }.filter { $0.versionFile.allFrameworks.isEmpty == false }
        
        return versionFiles.map {
            Dependency(
                name: $0.name,
                version: $0.versionFile.commitish,
                frameworks: $0.versionFile.allContainers.map {
                    .init(name: $0, path: buildDir.appending(component: $0))
                },
                versionFile: $0.path,
                hash: $0.versionFile.combinedHash
            )
        }
    }
}
