import Foundation
import TSCBasic

public typealias DownloadItem = (remotePath: String, localFile: AbsolutePath)

public protocol GCPDownloading {
    func download(items: [DownloadItem]) throws
}

public struct GCPDownloader: GCPDownloading {
    private let authAPI: AuthAPIServicing
    private let session: URLSession
    
    // MARK: - Initializers
    
    public init(authAPI: AuthAPIServicing = AuthAPIService(), session: URLSession = .shared) {
        self.authAPI = authAPI
        self.session = session
    }
    
    // MARK: - Public interface
    
    public func download(items: [DownloadItem]) throws {
        let bucket = try loadBucketName()
        let sa = try loadServiceAccount()
        let token = try authAPI.fetchAccessToken(serviceAccount: sa, validFor: 60, readOnly: false)
        
        try items.forEach { remotePath, localPath in
            let object = remotePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            var urlComponents = URLComponents(string: "https://storage.googleapis.com/upload/storage/v1/b/" + bucket + "/o/" + object)!
            urlComponents.queryItems = [
                .init(name: "alt", value: "media"),
            ]
            
            var request = URLRequest(url: urlComponents.url!)
            token.addToRequest(&request)
            request.httpMethod = "GET"
            request.httpBody = try Data(contentsOf: localPath.asURL)
            
            let data = try session.syncDataTask(for: request).0
            
            try data?.write(to: localPath.asURL)
        }
    }
}
