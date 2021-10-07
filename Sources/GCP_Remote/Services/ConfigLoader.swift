import Foundation

func loadServiceAccount(path: String) throws -> ServiceAccount {
    try JSONDecoder().decode(
        ServiceAccount.self,
        from: try Data(contentsOf: URL(fileURLExpandingTildeInPath: path))
    )
}

private extension URL {
    init(fileURLExpandingTildeInPath path: String) {
        self.init(fileURLWithPath: (path as NSString).expandingTildeInPath)
    }
}
