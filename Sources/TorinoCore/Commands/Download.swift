import ArgumentParser
import TSCBasic
import GCP_Remote

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
        
        let gcpDownloader: GCPDownloading? = {
            if let bucket = ProcessEnv.vars["TORINO_GCP_BUCKET"], bucket.count > 0 {
                return GCPDownloader(config: .init(bucket: bucket))
            }
            return nil
        }()
        
        try LocalDependenciesDownloader(gcpDownloader: gcpDownloader, pathProvider: pathProvider)
            .downloadDependencies(
                dependencies: lockfile.dependencies.map {
                    DownloadableDependency(name: $0.name, version: $0.version)
                }
            )
    }
}
