import CarthageKit
import Foundation
import XCDBLD

public protocol CachePathResolving {
    func path(for dependency: String, version: PinnedVersion, swiftVersion: String) -> String
    
    func frameworkPath(for dependency: String, platform: Platform, in project: Project) -> String
}

final class CachePathResolver: CachePathResolving {
    func path(for dependency: String, version: PinnedVersion, swiftVersion: String) -> String {
        [swiftVersion, dependency, version.commitish].joined(separator: "/")
    }
    
    func frameworkPath(for dependency: String, platform: Platform, in project: Project) -> String {
        [platform.relativePath, dependency + ".framework"].joined(separator: "/")
    }
}
