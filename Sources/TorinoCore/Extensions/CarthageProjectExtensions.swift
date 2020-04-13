import CarthageKit
import Foundation

internal extension Project {
    var rootBinariesURL: URL {
        directoryURL.appendingPathComponent(Constants.binariesFolderPath, isDirectory: true)
        .resolvingSymlinksInPath()
    }
}
