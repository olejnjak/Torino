import Foundation
import TSCBasic

public typealias DownloadItem = (remotePath: String, localFile: AbsolutePath)

public protocol GCPDownloading {
    func download(items: [DownloadItem]) throws
}

public struct GCPDownloader: GCPDownloading {
    private let authAPI: AuthAPIServicing
    private let session: URLSession
    private let fileSystem: FileSystem
    private let config: GCPConfig
    
    // MARK: - Initializers
    
    public init(
        authAPI: AuthAPIServicing = AuthAPIService(),
        fileSystem: FileSystem = localFileSystem,
        config: GCPConfig
    ) {
        self.init(authAPI: authAPI, session: .torino, fileSystem: fileSystem, config: config)
    }
    
    public init(
        authAPI: AuthAPIServicing = AuthAPIService(),
        session: URLSession,
        fileSystem: FileSystem = localFileSystem,
        config: GCPConfig
    ) {
        self.authAPI = authAPI
        self.session = session
        self.fileSystem = fileSystem
        self.config = config
    }
    
    // MARK: - Public interface
    
    public func download(items: [DownloadItem]) throws {
        guard items.count > 0 else { return }
        
        let sa = try loadServiceAccount(path: config.serviceAccountPath)
        let token = try authAPI.fetchAccessToken(serviceAccount: sa, validFor: 60, readOnly: false)
        
        try items.forEach { remotePath, localPath in
            let object = remotePath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var urlComponents = URLComponents(string: "https://storage.googleapis.com/download/storage/v1/b/" + config.bucket + "/o/" + object)!
            urlComponents.queryItems = [
                .init(name: "alt", value: "media"),
            ]
            
            var request = URLRequest(url: urlComponents.url!)
            token.addToRequest(&request)
            request.httpMethod = "GET"
            
            let data = try session.syncDataTask(for: request).0
            
            try? fileSystem.createDirectory(localPath.parentDirectory, recursive: true)
            try data?.write(to: localPath.asURL)
        }
    }
}
