import ArgumentParser
import Foundation
import GCP_Remote
import Logger
import TSCBasic

struct UploadError: Error {
    let message: String
}

struct Upload: ParsableCommand {
    @OptionGroup var args: SharedArguments
    
    func run() throws {
        let logger = Logger.shared
        
        guard let cwd = localFileSystem.currentWorkingDirectory else {
            throw UploadError(message: "Unable to get current working directory")
        }
        
        let prefix = try args.prefix ?? AutoPrefixService().autoPrefix()
        let pathProvider = try CarthagePathProvider(
            base: cwd,
            prefix: prefix
        )
        
        let gcpUploader: GCPUploading? = {
            do {
                return try GCPUploader(config: GCPConfig(environment: ProcessEnv.vars))
            } catch {
                logger.error("Unable to decode GCP configuration")
                logger.error(error.localizedDescription)
                logger.info("Remote cache will not be used")
            }
            
            return nil
        }()
        
        logger.info("Trying to upload cached dependencies with prefix", prefix)
        
        let group = DispatchGroup()
        
        group.enter()
        
        Task {
            try await UploadService(
                dependenciesLoader: CarthageDependenciesLoader(pathProvider: pathProvider),
                dependenciesUploader: LocalDependenciesUploader(pathProvider: pathProvider, gcpUploader: gcpUploader)
            ).run(path: cwd)
            
            group.leave()
        }
        
        group.wait()
    }
}
