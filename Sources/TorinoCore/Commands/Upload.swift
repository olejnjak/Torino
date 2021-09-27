import ArgumentParser
import TSCBasic

struct UploadError: Error {
    let message: String
}

struct Upload: ParsableCommand {
    func run() throws {
        guard let cwd = localFileSystem.currentWorkingDirectory else {
            throw UploadError(message: "Unable to get current working directory")
        }
        
        let pathProvider = try CarthagePathProvider(
            base: cwd,
            prefix: "Swift-5.5"
        )
        
        try UploadService(
            dependenciesLoader: CarthageDependenciesLoader(pathProvider: pathProvider),
            dependenciesUploader: LocalDependenciesUploader(pathProvider: pathProvider)
        ).run(path: cwd)
    }
}
