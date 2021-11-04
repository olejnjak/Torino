import Foundation
import TSCBasic
import Logger

public typealias DownloadItem = (remotePath: String, localFile: AbsolutePath)

public protocol GCPDownloading {
    func download(items: [DownloadItem]) throws
}

public struct GCPDownloader: GCPDownloading {
    private let authAPI: AuthAPIServicing
    private let session: URLSession
    private let fileSystem: FileSystem
    private let logger: Logging
    private let config: GCPConfig
    
    // MARK: - Initializers
    
    public init(
        authAPI: AuthAPIServicing = AuthAPIService(),
        fileSystem: FileSystem = localFileSystem,
        logger: Logging = Logger.shared,
        config: GCPConfig
    ) {
        self.init(
            authAPI: authAPI,
            session: .torino,
            fileSystem: fileSystem,
            logger: logger,
            config: config
        )
    }
    
    public init(
        authAPI: AuthAPIServicing = AuthAPIService(),
        session: URLSession,
        fileSystem: FileSystem = localFileSystem,
        logger: Logging = Logger.shared,
        config: GCPConfig
    ) {
        self.authAPI = authAPI
        self.session = session
        self.fileSystem = fileSystem
        self.logger = logger
        self.config = config
    }
    
    // MARK: - Public interface
    
    public func download(items: [DownloadItem]) throws {
        guard items.count > 0 else {
            logger.info("Nothing to download")
            return
        }
        
        let sa = try loadServiceAccount(path: config.serviceAccountPath)
        let token = try authAPI.fetchAccessToken(serviceAccount: sa, validFor: 60, readOnly: false)
        
        items.forEach { remotePath, localPath in
            let name = localPath.basenameWithoutExt
            
            logger.info("Downloading dependency", name)
            
            let object = remotePath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var urlComponents = URLComponents(string: "https://storage.googleapis.com/download/storage/v1/b/" + config.bucket + "/o/" + object)!
            urlComponents.queryItems = [
                .init(name: "alt", value: "media"),
            ]
            
            var request = URLRequest(url: urlComponents.url!)
            token.addToRequest(&request)
            request.httpMethod = "GET"
            
            do {
                let data = try session.syncDataTask(for: request).0
                
                try? fileSystem.createDirectory(
                    localPath.parentDirectory,
                    recursive: true
                )
                
                do {
                    try data?.write(to: localPath.asURL)
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
