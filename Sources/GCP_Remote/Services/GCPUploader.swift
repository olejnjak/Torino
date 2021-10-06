import Foundation
import TSCBasic

public protocol GCPUploading {
    func upload(_ file: AbsolutePath, to path: String) throws
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
    
    public func upload(_ file: AbsolutePath, to path: String) throws {
        let bucket = try loadBucketName()
        let sa = try loadServiceAccount()
        let token = try authAPI.fetchAccessToken(serviceAccount: sa, validFor: 60, readOnly: false)
        
        let url = URL(string: "https://storage.googleapis.com/upload/storage/v1/b/" + bucket + "/o?uploadType=media&name=" + path)!
        var request = URLRequest(url: url)
        token.addToRequest(&request)
        request.httpBody = try Data(contentsOf: file.asURL)
        _ = try session.syncDataTask(for: request)
    }
    
    // MARK: - Private helpers
    
    private func loadServiceAccount() throws -> ServiceAccount {
        try JSONDecoder().decode(ServiceAccount.self, from: try Data(contentsOf: URL(fileURLWithPath: "~/.Torino/sa.json")))
    }
    
    private func loadBucketName() throws -> String {
        try String(contentsOf: URL(fileURLWithPath: "~/.Torino/bucket")).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
