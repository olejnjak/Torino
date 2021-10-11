import Foundation

protocol AutoPrefixServicing {
    func autoPrefix() throws -> String
}

struct AutoPrefixError: Error {
    let message = "Cannot automatically get Swift version"
}

struct AutoPrefixService: AutoPrefixServicing {
    private let system: Systeming
    
    // MARK: - Initializers
    
    init(system: Systeming = System.shared) {
        self.system = system
    }
    
    // MARK: - Interface
    
    func autoPrefix() throws -> String {
        let swiftVersion = try system.run("swift", "-version")
        
        let regex = try NSRegularExpression(
            pattern: #"Swift Version ([0-9]+\.[0-9]+(\.[0-9]+)?)"#,
            options: .caseInsensitive
        )
        let results = regex.matches(
            in: swiftVersion,
            range: NSRange(swiftVersion.startIndex..., in: swiftVersion)
        )
        
        if let result = results.first {
            for rangeIndex in 0..<result.numberOfRanges {
                let matchRange = result.range(at: rangeIndex)
                
                if matchRange == result.range { continue }
                
                return "Swift-" + (swiftVersion as NSString).substring(with: matchRange)
            }
        }
        
        throw AutoPrefixError()
    }
}
