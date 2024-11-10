import Foundation
import GoogleAuth

public protocol GCPAPIServicing {
    func downloadObject(
        _ object: String,
        bucket: String,
        token: Token
    ) async throws -> Data
    
    func upload(
        file: URL,
        object: String,
        bucket: String,
        token: Token
    ) async throws
    
    func metadata(
        object: String,
        bucket: String,
        token: Token
    ) async throws -> Metadata
    
    func updateMetadata(
        _ metadata: Metadata,
        object: String,
        bucket: String,
        token: Token
    ) async throws
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
        token: Token
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
        
        return try await session.data(for: request).0
    }
    
    public func upload(
        file: URL,
        object: String,
        bucket: String,
        token: Token
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

        _ = try await session.upload(for: request, fromFile: file)
    }
    
    public func metadata(
        object: String,
        bucket: String,
        token: Token
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
            from: session.data(for: request).0
        )
    }
    
    public func updateMetadata(
        _ metadata: Metadata,
        object: String,
        bucket: String,
        token: Token
    ) async throws {
        var request = URLRequest(url: .init(string: "https://storage.googleapis.com/storage/v1/b/\(bucket)/o/\(object.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")!)
        token.addToRequest(&request)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(metadata)
        
        _ = try await session.data(for: request)
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
