import Foundation
import TSCBasic

public typealias UploadItem = (localFile: AbsolutePath, remotePath: String)

public protocol GCPUploading {
    func upload(items: [UploadItem]) throws
}

public struct GCPUploader: GCPUploading {
    private let authAPI: AuthAPIServicing
    private let session: URLSession
    private let config: GCPConfig
    
    // MARK: - Initializers
    
    public init(authAPI: AuthAPIServicing = AuthAPIService(), session: URLSession = .shared, config: GCPConfig) {
        self.authAPI = authAPI
        self.session = session
        self.config = config
    }
    
    // MARK: - Public nterface
    
    public func upload(items: [UploadItem]) throws {
        guard items.count > 0 else { return }
        
        let sa = try loadServiceAccount()
        let token = try authAPI.fetchAccessToken(serviceAccount: sa, validFor: 60, readOnly: false)
        
        try items.forEach { localPath, remotePath in
            var urlComponents = URLComponents(string: "https://storage.googleapis.com/upload/storage/v1/b/" + config.bucket + "/o")!
            urlComponents.queryItems = [
                .init(name: "uploadType", value: "media"),
                .init(name: "name", value: remotePath),
            ]
            
            var request = URLRequest(url: urlComponents.url!)
            token.addToRequest(&request)
            request.httpMethod = "POST"
            request.httpBody = try Data(contentsOf: localPath.asURL)
            _ = try session.syncDataTask(for: request)
        }
    }
}
