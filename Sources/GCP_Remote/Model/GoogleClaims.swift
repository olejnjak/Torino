import Foundation
import SwiftJWT

/// Struct that is used for generating second part of JWT token
struct GoogleClaims: Claims {
    /// Service account email
    let iss: String

    /// Required scope
    let scope: String

    /// Desired auth endpoint
    let aud: URL

    /// Date of expiration timestamp
    let exp: Int

    /// Issued at date timestamp
    let iat: Int

    private init(iss: String, scope: String, exp: Int, iat: Int) {
        self.iss = iss
        self.scope = scope
        self.aud = URL(string: "https://oauth2.googleapis.com/token")!
        self.exp = exp
        self.iat = iat
    }
}

extension GoogleClaims {
    static func readOnly(iss: String, exp: Int, iat: Int) -> GoogleClaims {
        .init(iss: iss, scope: "https://www.googleapis.com/auth/devstorage.read_only", exp: exp, iat: iat)
    }

    static func readWrite(iss: String, exp: Int, iat: Int) -> GoogleClaims {
        .init(iss: iss, scope: "https://www.googleapis.com/auth/devstorage.read_write", exp: exp, iat: iat)
    }
}
