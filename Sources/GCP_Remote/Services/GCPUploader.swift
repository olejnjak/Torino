import Foundation
import TSCBasic

public protocol GCPUploading {
    func upload(_ file: AbsolutePath, to path: String) throws
}

struct GCPUploader: GCPUploading {
    func upload(_ file: AbsolutePath, to path: String) throws {
        // TODO: Implement
    }
}
