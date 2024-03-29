import Foundation
import JWTKit

/// Protocol wrapping a service that fetches an access token from further communication
public protocol AuthAPIServicing {
    /// Fetch access token for given `serviceAccount`
    func fetchAccessToken(
        serviceAccount: ServiceAccount,
        validFor interval: TimeInterval,
        readOnly: Bool
    ) async throws -> AccessToken
}

/// Service that fetches an access token from further communication
public struct AuthAPIService: AuthAPIServicing {
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initializers
    
    public init() {
        self.init(session: .torino)
    }
    
    public init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - API calls
    
    /// Fetch access token for given `serviceAccount`
    public func fetchAccessToken(
        serviceAccount: ServiceAccount,
        validFor interval: TimeInterval,
        readOnly: Bool
    ) async throws -> AccessToken {
        let claims = self.claims(serviceAccount: serviceAccount, validFor: interval, readOnly: readOnly)
        let jwt = try self.jwt(for: serviceAccount, claims: claims)
        let requestData = AccessTokenRequest(assertion: jwt)
        var request = URLRequest(url: claims.aud)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(requestData)
        return try await decoder.decode(
            AccessToken.self,
            from: session.data(request: request).0
        )
    }
    
    // MARK: - Private helpers
    
    /// Create JWT token that will be sent to retrieve access token
    private func jwt(for serviceAccount: ServiceAccount, claims: GoogleClaims) throws -> String {
        let signers = JWTSigners()
        try signers.use(.rs256(key: .private(pem: serviceAccount.privateKey)))
        return try signers.sign(claims)
    }
    
    private func claims(serviceAccount sa: ServiceAccount, validFor interval: TimeInterval, readOnly: Bool) -> GoogleClaims {
        let now = Int(Date().timeIntervalSince1970)

        return .init(serviceAccount: sa, scope: readOnly ? .readOnly : .readWrite, exp: now + Int(interval), iat: now)
    }
}
