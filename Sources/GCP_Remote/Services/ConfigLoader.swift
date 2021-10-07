import Foundation

func loadServiceAccount() throws -> ServiceAccount {
    try JSONDecoder().decode(
        ServiceAccount.self,
        from: try Data(contentsOf: URL(fileURLExpandingTildeInPath: "~/.Torino/gcp_sa.json"))
    )
}

private extension URL {
    init(fileURLExpandingTildeInPath path: String) {
        self.init(fileURLWithPath: (path as NSString).expandingTildeInPath)
    }
}
