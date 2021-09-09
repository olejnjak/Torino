import Foundation
import TSCBasic

public struct VersionFilePath {
    public let name: String
    public let path: AbsolutePath
    
    public init(path: AbsolutePath) {
        self.path = path
        
        if path.basenameWithoutExt.first == "." {
            var name = path.basenameWithoutExt
            name.removeFirst()
            self.name = name
        } else {
            name = path.basenameWithoutExt
        }
    }
}
