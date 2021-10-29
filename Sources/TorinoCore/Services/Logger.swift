import Foundation
import TSCUtility

protocol Logging {
    func logStdout(_ output: String...)
    func info(_ info: String...)
}

struct Logger: Logging {
    static let shared = Logger()
    
    private init() {
        
    }
    
    func logStdout(_ output: String...) {
        print(type: "[OUTPUT]", output: output)
    }
    
    func info(_ info: String...) {
        print(type: "[INFO]", output: info)
    }
    
    func error(_ error: String...) {
        print(type: "[ERROR]", output: error)
    }
    
    private func print(type: String, output: [String]) {
        Swift.print(
            type,
            output.map { $0.trimmingCharacters(in: .newlines).replacingOccurrences(of: "\n", with: "\n" + type) }
                .joined(separator: " ")
        )
    }
}
