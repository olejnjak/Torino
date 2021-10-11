import ArgumentParser
import TSCBasic
import GCP_Remote

struct DownloadError: Error {
    let message: String
}

struct Download: ParsableCommand {
    @OptionGroup var args: SharedArguments
    
    func run() throws {
        guard let cwd = localFileSystem.currentWorkingDirectory else {
            throw UploadError(message: "Unable to get current working directory")
        }
        
        let pathProvider = try CarthagePathProvider(
            base: cwd,
            prefix: args.prefix
        )
        
        let lockfilePath = pathProvider.lockfile()
        let lockfileContent = try localFileSystem.readFileContents(lockfilePath)
        let lockfile = Lockfile.from(string: lockfileContent.cString)
        
        let gcpDownloader = (try? GCPConfig(environment: ProcessEnv.vars))
            .map { GCPDownloader(config: $0) }
        
        try LocalDependenciesDownloader(gcpDownloader: gcpDownloader, pathProvider: pathProvider)
            .downloadDependencies(
                dependencies: lockfile.dependencies.map {
                    DownloadableDependency(name: $0.name, version: $0.version)
                }
            )
    }
}
