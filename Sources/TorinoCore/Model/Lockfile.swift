import Foundation

/// Model for Cartfile.resolved
struct Lockfile {
    struct Item {
        let type: String
        let source: String
        let version: String
        
        var name: String {
            guard let lastComponent = source.components(separatedBy: "/").last else { return "" }
            
            if lastComponent.hasSuffix(".git") {
                return String(lastComponent[lastComponent.startIndex..<lastComponent.index(lastComponent.endIndex, offsetBy: -4)])
            }
            
            return lastComponent
        }
    }
    
    let dependencies: [Item]
}

extension Lockfile {
    static func from(string: String) -> Lockfile {
        let rows = string.components(separatedBy: "\n")
            .filter { $0.count > 0 }
        
        return .init(dependencies: rows.compactMap(Item.from))
    }
}

extension Lockfile.Item {
    static func from(row: String) -> Lockfile.Item? {
        let components = row.components(separatedBy: " ")
        
        guard components.count == 3 else { return nil }
        
        let type = components[0]
        let source = components[1].replacingOccurrences(of: #"""#, with: "")
        let version = components[2].replacingOccurrences(of: #"""#, with: "")
        
        return .init(type: type, source: source, version: version)
    }
}
