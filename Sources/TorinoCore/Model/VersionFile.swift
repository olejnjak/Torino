import Foundation
import TSCBasic

public struct VersionFile: Decodable {
    public struct Framework: Decodable {
        public let name: String
        public let container: String?
    }
    
    public let commitish: String
    public let iOS: [Framework]?
    public let macOS: [Framework]?
    public let tvOS: [Framework]?
    public let watchOS: [Framework]?
    
    public var allContainers: [String] {
        [iOS, macOS, tvOS, watchOS].compactMap { $0 }
            .joined()
            .compactMap(\.container)
    }
}

public struct VersionFileWithName {
    public let name: String
    public let versionFile: VersionFile
    public let path: AbsolutePath
}
