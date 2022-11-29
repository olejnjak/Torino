import ArgumentParser
import Foundation
import GCP_Remote
import Logger
import TSCBasic

struct DownloadError: Error {
    let message: String
}

struct Download: ParsableCommand {
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
        
        let lockfilePath = pathProvider.lockfile()
        
        guard localFileSystem.exists(lockfilePath) else {
            logger.info("No Cartfile.resolved found at '\(lockfilePath)', finishing early")
            return
        }
        
        let lockfileContent = try localFileSystem.readFileContents(lockfilePath)
        let lockfile = Lockfile.from(string: lockfileContent.cString)
        
        let gcpDownloader: GCPDownloading? = {
            do {
                return try GCPDownloader(config: GCPConfig(environment: ProcessEnv.vars))
            } catch {
                logger.error("Unable to decode GCP configuration")
                logger.error(error.localizedDescription)
                logger.info("Remote cache will not be used")
            }
            
            return nil
        }()
        
        let group = DispatchGroup()
        
        group.enter()
        
        Task {
            logger.info("Trying to download cached dependencies with prefix", prefix)
            try await LocalDependenciesDownloader(
                gcpDownloader: gcpDownloader,
                pathProvider: pathProvider
            ).downloadDependencies(
                dependencies: lockfile.dependencies.map {
                    DownloadableDependency(name: $0.name, version: $0.version)
                }
            )
            
            group.leave()
        }
        
        group.wait()
    }
}
