import Foundation

protocol Logging {
    func logStdout(_ output: String...)
    func info(_ info: String...)
}

struct Logger: Logging {
    static let shared = Logger()
    
    private init() {
        
    }
    
    func logStdout(_ output: String...) {
        print(
            "[OUTPUT]",
            output.map { $0.trimmingCharacters(in: .newlines) }
                .joined(separator: " ")
        )
    }
    
    func info(_ info: String...) {
        print(
            "[INFO]",
            info.map { $0.trimmingCharacters(in: .newlines) }
                .joined(separator: " ")
        )
    }
}
