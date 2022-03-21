import Foundation

public struct Metadata: Codable {
    public struct CustomMetadata: Codable {
        public let carthageHash: String?
    }
    
    public let metadata: CustomMetadata?
}
