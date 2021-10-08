import Foundation

/// Struct holding necessary information about service account which should access spreadsheet
public struct ServiceAccount: Decodable {
    enum CodingKeys: String, CodingKey {
        case clientEmail = "client_email"
        case privateKey = "private_key"
    }
    
    /// Email associated with the service account
    let clientEmail: String
    
    /// Private key used to generate JWT token
    let privateKey: String
    
    // MARK: - Initializers
    
    init(clientEmail: String, privateKey: String) {
        self.clientEmail = clientEmail
        self.privateKey = privateKey
    }
}