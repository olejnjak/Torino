import CarthageKit
import Foundation

public struct DependencyMismatch {
    let dependency: Dependency
    let resolvedVersion: PinnedVersion?
    let versionFileCommitish: String?
}
