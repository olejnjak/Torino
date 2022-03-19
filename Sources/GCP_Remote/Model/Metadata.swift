import Foundation

public struct Metadata: Codable {
    public let crc32c: String
    public let etag: String
    public let md5Hash: String
}
