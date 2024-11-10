import Foundation

private extension URL {
    init(fileURLExpandingTildeInPath path: String) {
        self.init(fileURLWithPath: (path as NSString).expandingTildeInPath)
    }
}
