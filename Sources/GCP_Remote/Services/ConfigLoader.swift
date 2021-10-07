import Foundation

func loadServiceAccount() throws -> ServiceAccount {
    try JSONDecoder().decode(
        ServiceAccount.self,
        from: try Data(contentsOf: URL(fileURLExpandingTildeInPath: "~/.Torino/sa.json"))
    )
}

func loadBucketName() throws -> String {
    try String(contentsOf: URL(fileURLExpandingTildeInPath: "~/.Torino/bucket"))
        .trimmingCharacters(in: .whitespacesAndNewlines)
}

private extension URL {
    init(fileURLExpandingTildeInPath path: String) {
        self.init(fileURLWithPath: (path as NSString).expandingTildeInPath)
    }
}
