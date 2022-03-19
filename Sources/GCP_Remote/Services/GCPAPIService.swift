import Foundation

public protocol GCPAPIServicing {
    func downloadObject(
        _ object: String,
        bucket: String,
        token: AccessToken
    ) async throws -> Data
    
    func upload(
        file: URL,
        object: String,
        bucket: String,
        token: AccessToken
    ) async throws
    
    func metadata(
        object: String,
        bucket: String,
        token: AccessToken
    ) async throws -> Metadata
}

public final class GCPAPIService: GCPAPIServicing {
    private enum Action: String {
        case download, upload, get = ""
    }
    
    private let session: URLSession
    
    // MARK: - Initializers
    
    public convenience init() {
        self.init(session: .torino)
    }
    
    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - Interface
    
    public func downloadObject(
        _ object: String,
        bucket: String,
        token: AccessToken
    ) async throws -> Data {
        var urlComponents = URLComponents(string: url(
            action: .download,
            bucket: bucket,
            object: object).absoluteString)!
        urlComponents.queryItems = [
            .init(name: "alt", value: "media"),
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        token.addToRequest(&request)
        request.httpMethod = "GET"
        
        return try await session.data(request: request).0
    }
    
    public func upload(
        file: URL,
        object: String,
        bucket: String,
        token: AccessToken
    ) async throws {
        var urlComponents = URLComponents(string: url(
            action: .upload,
            bucket: bucket,
            object: nil).absoluteString)!
        urlComponents.queryItems = [
            .init(name: "uploadType", value: "media"),
            .init(name: "name", value: object),
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        token.addToRequest(&request)
        request.setValue("application/zip", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        try await session.upload(request: request, fromFile: file)
    }
    
    public func metadata(
        object: String,
        bucket: String,
        token: AccessToken
    ) async throws -> Metadata {
        var request = URLRequest(url: url(
            action: .get,
            bucket: bucket,
            object: object
        ))
        token.addToRequest(&request)
        request.httpMethod = "GET"
        return try await JSONDecoder().decode(
            Metadata.self,
            from: session.data(request: request).0
        )
    }
    
    // MARK: - Private helpers
    
    private func url(
        action: Action,
        bucket: String,
        object: String?
    ) -> URL {
        .init(string: [
            "https://storage.googleapis.com",
            action.rawValue,
            "storage/v1/b",
            bucket,
            "o",
            object?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
        ].compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: "/"))!
    }
}
