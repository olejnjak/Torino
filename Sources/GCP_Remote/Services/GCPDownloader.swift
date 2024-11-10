import Foundation
import GoogleAuth
import TSCBasic
import Logger

public typealias DownloadItem = (remotePath: String, localFile: AbsolutePath)

public protocol GCPDownloading {
    func download(items: [DownloadItem]) async throws
}

public struct GCPDownloader: GCPDownloading {
    private let gcpAPI: GCPAPIServicing
    private let fileSystem: FileSystem
    private let logger: Logging
    private let config: GCPConfig
    
    // MARK: - Initializers
    
    public init(
        gcpAPI: GCPAPIServicing = GCPAPIService(),
        fileSystem: FileSystem = localFileSystem,
        logger: Logging = Logger.shared,
        config: GCPConfig
    ) {
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

        let tokenProvider: TokenProvider
        let scopes = ["https://www.googleapis.com/auth/devstorage.full_control"]

        if let saPath = config.serviceAccountPath {
            tokenProvider = try await ServiceAccountTokenProvider(
                serviceAccountPath: saPath,
                scopes: scopes
            )
        } else if let provider = await DefaultCredentialsTokenProvider(scopes: scopes) {
            tokenProvider = provider
        } else {
            struct CannotCreateProvider: Error { }
            throw CannotCreateProvider()
        }

        let token = try await tokenProvider.token()

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
