import Foundation
import SwiftJWT

/// Struct that is used for generating second part of JWT token
struct GoogleClaims: Claims {
    enum Scope: String, Codable {
        case readOnly = "https://www.googleapis.com/auth/devstorage.read_only"
        case readWrite = "https://www.googleapis.com/auth/devstorage.read_write"
    }
    
    /// Service account email
    let iss: String

    /// Required scope
    let scope: Scope

    /// Desired auth endpoint
    let aud: URL

    /// Date of expiration timestamp
    let exp: Int

    /// Issued at date timestamp
    let iat: Int
}

extension GoogleClaims {
    init(serviceAccount: ServiceAccount, scope: Scope, exp: Int, iat: Int) {
        self.init(iss: serviceAccount.clientEmail, scope: scope, aud: serviceAccount.tokenURL, exp: exp, iat: iat)
    }
}
