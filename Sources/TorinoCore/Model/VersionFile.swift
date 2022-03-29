import CryptoKit
import Foundation
import TSCBasic

public struct VersionFile: Decodable {
    public struct Framework: Decodable {
        public let name: String
        public let container: String?
        public let hash: String
    }
    
    public let commitish: String
    public let iOS: [Framework]?
    public let macOS: [Framework]?
    public let tvOS: [Framework]?
    public let watchOS: [Framework]?
    
    public var allContainers: [String] {
        allFrameworks.compactMap(\.container)
    }
    
    public var combinedHash: String {
        let allHashes = allFrameworks.reduce("") { partialResult, container in
            partialResult + String(container.hash.count) + container.hash
        }
        
        return Data(Insecure.MD5.hash(data: allHashes.data(using: .utf8)!))
            .base64EncodedString()
    }
    
    public var allFrameworks: [Framework] {
        [iOS, macOS, tvOS, watchOS]
            .compactMap { $0 }
            .flatMap { $0 }
            .filter { ($0.container ?? "").isEmpty == false }
    }
}

public struct VersionFileWithName {
    public let name: String
    public let versionFile: VersionFile
    public let path: AbsolutePath
}
