import Foundation

public struct GCPConfig: Decodable {
    enum CodingKeys: String, CodingKey {
        case bucket = "TORINO_GCP_BUCKET"
        case serviceAccountPath = "TORINO_GCP_SERVICE_ACCOUNT_PATH"
    }
    
    public let bucket: String
    public let serviceAccountPath: String
    
    public init(bucket: String, serviceAccountPath: String) {
        self.bucket = bucket
        self.serviceAccountPath = serviceAccountPath
    }
    
    public init(environment: [String: String]) throws {
        let data = try JSONEncoder().encode(environment)
        self = try JSONDecoder().decode(Self, from: data)
    }
}
