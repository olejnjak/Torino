import Foundation

protocol AutoPrefixServicing {
    func autoPrefix() throws -> String
}

struct AutoPrefixError: Error {
    let message = "Cannot automatically get Swift version"
}

struct AutoPrefixService: AutoPrefixServicing {
    private let system: Systeming
    private let logger: Logging
    
    // MARK: - Initializers
    
    init(
        system: Systeming = System.shared,
        logger: Logging = Logger.shared
    ) {
        self.system = system
        self.logger = logger
    }
    
    // MARK: - Interface
    
    func autoPrefix() throws -> String {
        logger.info("Trying to automatically detect cache prefix")
        
        let swiftVersion = try system.run("swift", "-version", suppressOutput: true)
        
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
                
                let prefix = "Swift-" + (swiftVersion as NSString).substring(with: matchRange)
                
                logger.info("Detected cache prefix is", prefix)
                
                return prefix
            }
        }
        
        throw AutoPrefixError()
    }
}
