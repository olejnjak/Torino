import Foundation
import TSCBasic

public typealias UploadItem = (localFile: AbsolutePath, remotePath: String)

public protocol GCPUploading {
    func upload(items: [UploadItem]) throws
}

public struct GCPUploader: GCPUploading {
    private let authAPI: AuthAPIServicing
    private let session: URLSession
    
    // MARK: - Initializers
    
    public init(authAPI: AuthAPIServicing = AuthAPIService(), session: URLSession = .shared) {
        self.authAPI = authAPI
        self.session = session
    }
    
    // MARK: - Interface
    
    public func upload(items: [UploadItem]) throws {
        let bucket = try loadBucketName()
        let sa = try loadServiceAccount()
        let token = try authAPI.fetchAccessToken(serviceAccount: sa, validFor: 60, readOnly: false)
        
        try items.forEach { localPath, remotePath in
            var urlComponents = URLComponents(string: "https://storage.googleapis.com/upload/storage/v1/b/" + bucket + "/o")!
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
    
    // MARK: - Private helpers
    
    private func loadServiceAccount() throws -> ServiceAccount {
        try JSONDecoder().decode(
            ServiceAccount.self,
            from: try Data(contentsOf: URL(fileURLExpandingTildeInPath: "~/.Torino/sa.json"))
        )
    }
    
    private func loadBucketName() throws -> String {
        try String(contentsOf: URL(fileURLExpandingTildeInPath: "~/.Torino/bucket"))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension URL {
    init(fileURLExpandingTildeInPath path: String) {
        self.init(fileURLWithPath: (path as NSString).expandingTildeInPath)
    }
}
