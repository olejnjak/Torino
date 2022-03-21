import Foundation
import TSCBasic
import Logger

public typealias DownloadItem = (remotePath: String, localFile: AbsolutePath)

public protocol GCPDownloading {
    func download(items: [DownloadItem]) async throws
}

public struct GCPDownloader: GCPDownloading {
    private let authAPI: AuthAPIServicing
    private let gcpAPI: GCPAPIServicing
    private let fileSystem: FileSystem
    private let logger: Logging
    private let config: GCPConfig
    
    // MARK: - Initializers
    
    public init(
        authAPI: AuthAPIServicing = AuthAPIService(),
        gcpAPI: GCPAPIServicing = GCPAPIService(),
        fileSystem: FileSystem = localFileSystem,
        logger: Logging = Logger.shared,
        config: GCPConfig
    ) {
        self.authAPI = authAPI
        self.gcpAPI = gcpAPI
        self.fileSystem = fileSystem
        self.logger = logger
        self.config = config
    }
    
    // MARK: - Public interface
    
    public func download(items: [DownloadItem]) async throws {
        guard items.count > 0 else {
            logger.info("Nothing to download")
            return
        }
        
        let sa = try loadServiceAccount(path: config.serviceAccountPath)
        let token = try await authAPI.fetchAccessToken(
            serviceAccount: sa,
            validFor: 60,
            readOnly: false
        )
        
        await items.asyncForEach { object, localPath in
            let name = localPath.basenameWithoutExt
            
            logger.info("Downloading dependency", name)
            
            do {
                let data = try await gcpAPI.downloadObject(
                    object,
                    bucket: config.bucket,
                    token: token
                )
                
                try? fileSystem.createDirectory(
                    localPath.parentDirectory,
                    recursive: true
                )
                
                do {
                    try data.write(to: localPath.asURL)
                    logger.info("Successfully downloaded dependency", name)
                } catch {
                    logger.error("Unable to write data for dependency", name)
                }
            } catch {
                logger.info("Unable to fetch dependency", name)
                logger.info(error.localizedDescription)
            }
        }
    }
}
