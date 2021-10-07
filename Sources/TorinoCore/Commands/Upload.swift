import ArgumentParser
import TSCBasic
import GCP_Remote

struct UploadError: Error {
    let message: String
}

struct Upload: ParsableCommand {
    @Option var prefix: String
    
    func run() throws {
        guard let cwd = localFileSystem.currentWorkingDirectory else {
            throw UploadError(message: "Unable to get current working directory")
        }
        
        let pathProvider = try CarthagePathProvider(
            base: cwd,
            prefix: prefix
        )
        
        let gcpUploader: GCPUploading? = {
            if let bucket = ProcessEnv.vars["TORINO_GCP_BUCKET"], bucket.count > 0 {
                return GCPUploader(config: .init(bucket: bucket))
            }
            return nil
        }()
        
        try UploadService(
            dependenciesLoader: CarthageDependenciesLoader(pathProvider: pathProvider),
            dependenciesUploader: LocalDependenciesUploader(pathProvider: pathProvider, gcpUploader: gcpUploader)
        ).run(path: cwd)
    }
}
