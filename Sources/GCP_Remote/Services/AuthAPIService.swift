import Foundation
import SwiftJWT

/// Protocol wrapping a service that fetches an access token from further communication
public protocol AuthAPIServicing {
    /// Fetch access token for given `serviceAccount`
    func fetchAccessToken(serviceAccount: ServiceAccount, readOnly: Bool) throws -> AccessToken
}

/// Service that fetches an access token from further communication
struct AuthAPIService: AuthAPIServicing {
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initializers
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - API calls
    
    /// Fetch access token for given `serviceAccount`
    func fetchAccessToken(serviceAccount: ServiceAccount, readOnly: Bool) throws -> AccessToken {
        let jwt = self.jwt(for: serviceAccount, claims: claims(serviceAccount: serviceAccount, readOnly: readOnly))
        let url = URL(string: "https://oauth2.googleapis.com/token")!
        let requestData = AccessTokenRequest(assertion: jwt)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? encoder.encode(requestData)
        return try decoder.decode(AccessToken.self, from: try session.syncDataTask(for: request).0 ?? Data())
    }
    
    // MARK: - Private helpers
    
    /// Create JWT token that will be sent to retrieve access token
    private func jwt(for serviceAccount: ServiceAccount, claims: GoogleClaims) -> String {
        let header = Header(typ: "JWT")
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.rs256(privateKey: serviceAccount.privateKey.data(using: .utf8)!)
        return (try? jwt.sign(using: signer)) ?? ""
    }
    
    private func claims(serviceAccount: ServiceAccount, readOnly: Bool) -> GoogleClaims {
        let now = Int(Date().timeIntervalSince1970)
        
        if readOnly {
            return GoogleClaims.readOnly(iss: serviceAccount.clientEmail, exp: now + 60, iat: now)
        }
        return GoogleClaims.readWrite(iss: serviceAccount.clientEmail, exp: now + 60, iat: now)
    }
}

private extension URLSession {
    func syncDataTask(for request: URLRequest) throws -> (Data?, URLResponse?) {
        let semaphore = DispatchSemaphore(value: 0)
        
        var resultData: Data?
        var resultResponse: URLResponse?
        var resultError: Error?
        
        let task = dataTask(with: request) { data, response, error in
            resultData = data
            resultResponse = response
            resultError = error
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        if let error = resultError {
            throw error
        }
        
        return (resultData, resultResponse)
    }
}
