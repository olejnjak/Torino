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
        let buildDir = pathProvider.buildDir()
        
        try dependencies.forEach { dependency in
            let cachePath = pathProvider.cacheDir(
                dependency: dependency.name,
                version: dependency.version
            )
        
            try? fileSystem.createDirectory(cachePath.parentDirectory, recursive: true)
        
            let paths = dependency.frameworks.map { $0.path.relative(to: buildDir).pathString }
            
            do {
                try shell([
                    "zip", "-ruq",
                    cachePath.pathString,
                    dependency.versionFile.relative(to: buildDir).pathString,
                ] + paths, cwd: buildDir)
            } catch let error as ShellError {
                if error.code != 12 { // zip has nothing to do
                    throw error
                }
            }
        }
    }
}

struct ShellError: Error {
    let code: Int32
}

func shell(_ args: String..., cwd: AbsolutePath?) throws {
    try shell(Array(args), cwd: cwd)
}

func shell(_ args: [String], cwd: AbsolutePath?) throws {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.currentDirectoryURL = cwd?.asURL
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    
    if task.terminationStatus != 0 {
        throw ShellError(code: task.terminationStatus)
    }
}
