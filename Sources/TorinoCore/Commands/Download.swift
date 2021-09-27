import ArgumentParser
import TSCBasic

struct DownloadError: Error {
    let message: String
}

struct Download: ParsableCommand {
    @Option var prefix: String
    
    func run() throws {
        guard let cwd = localFileSystem.currentWorkingDirectory else {
            throw UploadError(message: "Unable to get current working directory")
        }
        
        let pathProvider = try CarthagePathProvider(
            base: cwd,
            prefix: prefix
        )
        
        let lockfilePath = pathProvider.lockfile()
        let lockfileContent = try localFileSystem.readFileContents(lockfilePath)
        let lockfile = Lockfile.from(string: lockfileContent.cString)
        
        try LocalDependenciesDownloader(pathProvider: pathProvider)
            .downloadDependencies(
                dependencies: lockfile.dependencies.map {
                    DownloadableDependency(name: $0.name, version: $0.version)
                }
            )
    }
}
