import Foundation
import TSCBasic

public struct Dependency {
    public struct Container {
        let name: String
        let path: AbsolutePath
    }
    
    public let name: String
    public let version: String
    public let frameworks: [Container]
}
