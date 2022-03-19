import Foundation

protocol GCPAPIServicing {
    func downloadObject(
        _ object: String,
        bucket: String,
        token: AccessToken
    ) async throws -> Data
    
    func uploadData(
        _ data: Data,
        object: String,
        bucket: String,
        token: AccessToken
    ) async throws
}

final class GCPAPIService: GCPAPIServicing {
    private enum Action: String {
        case download, upload
    }
    
    private let session: URLSession
    
    // MARK: - Initializers
    
    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - Interface
    
    func downloadObject(
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
    
    func uploadData(
        _ data: Data,
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
        request.httpBody = data
        
        _ = try await session.data(request: request)
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
            object,
        ].compactMap { $0 }.joined(separator: "/"))!
    }
}
