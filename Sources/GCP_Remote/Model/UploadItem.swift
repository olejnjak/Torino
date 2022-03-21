import Foundation
import TSCBasic

public struct UploadItem {
    public let localFile: AbsolutePath
    public let remotePath: String
    public let hash: String
    
    // MARK: - Initializers
    
    public init(
        localFile: AbsolutePath,
        remotePath: String,
        hash: String
    ) {
        self.localFile = localFile
        self.remotePath = remotePath
        self.hash = hash
    }
}
