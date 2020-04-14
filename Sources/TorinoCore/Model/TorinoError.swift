import CarthageKit
import Foundation

/// Error that is thrown throughout the project
public enum TorinoError: Error {
    /// Error thrown by CarthageKit
    case carthage(CarthageError)
    /// Version files in `Carthage/Build` don't match with _Cartfile.resolved_
    ///
    /// Dependencies with 
    case versionFileMismatch([DependencyMismatch])
    
    case unknown(description: String)
}

internal extension TorinoError {
    /// Convenience init for errors thrown by `CarthageKit`
    init(carthageError: CarthageError) {
        self = .carthage(carthageError)
    }
    
    /// Convenience init for errors thrown by `CarthageKit`
    init(swiftError: SwiftVersionError) {
        let carthageError = CarthageError.internalError(description: swiftError.description)
        self.init(carthageError: carthageError)
    }
}
