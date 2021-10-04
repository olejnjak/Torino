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
        
            try? fileSystem.removeFileTree(cachePath)
            try? fileSystem.createDirectory(cachePath.parentDirectory, recursive: true)
        
            let paths = dependency.frameworks.map { $0.path.relative(to: buildDir).pathString }
            
            try shell([
                "zip", "-r",
                cachePath.pathString,
                dependency.versionFile.relative(to: buildDir).pathString, ";"
            ] + paths, cwd: buildDir.asURL)
        }
    }
}

struct ShellError: Error {
    let code: Int32
}

func shell(_ args: String..., cwd: URL?) throws {
    try shell(Array(args), cwd: cwd)
}

func shell(_ args: [String], cwd: URL?) throws {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.currentDirectoryURL = cwd
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    
    if task.terminationStatus != 0 {
        throw ShellError(code: task.terminationStatus)
    }
}
