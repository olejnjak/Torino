import ArgumentParser
import TSCBasic
import GCP_Remote

struct UploadError: Error {
    let message: String
}

struct Upload: ParsableCommand {
    @OptionGroup var args: SharedArguments
    
    func run() throws {
        guard let cwd = localFileSystem.currentWorkingDirectory else {
            throw UploadError(message: "Unable to get current working directory")
        }
        
        let pathProvider = try CarthagePathProvider(
            base: cwd,
            prefix: args.prefix
        )
        
        let gcpUploader = (try? GCPConfig(environment: ProcessEnv.vars))
            .map { GCPUploader(config: $0) }
        
        try UploadService(
            dependenciesLoader: CarthageDependenciesLoader(pathProvider: pathProvider),
            dependenciesUploader: LocalDependenciesUploader(pathProvider: pathProvider, gcpUploader: gcpUploader)
        ).run(path: cwd)
    }
}
