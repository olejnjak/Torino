import Foundation

public struct GCPConfig: Decodable {
    public let bucket: String
    
    public init(bucket: String) {
        self.bucket = bucket
    }
}
