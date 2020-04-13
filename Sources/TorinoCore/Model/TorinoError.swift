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
}

internal extension TorinoError {
    /// Convenience init for errors thrown by `CarthageKit`
    init(carthageError: CarthageError) {
        self = .carthage(carthageError)
    }
}
