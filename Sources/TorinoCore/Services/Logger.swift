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
        print(type: "[OUTPUT]", output: output, to: &StandardOutputStream.stdout)
    }
    
    func info(_ info: String...) {
        print(type: "[INFO]", output: info, to: &StandardOutputStream.stdout)
    }
    
    func error(_ error: String...) {
        print(type: "[ERROR]", output: error, to: &StandardOutputStream.stderr)
    }
    
    private func print<Stream: TextOutputStream>(type: String, output: [String], to stream: inout Stream) {
        Swift.print(
            type,
            output.map { $0.trimmingCharacters(in: .newlines).replacingOccurrences(of: "\n", with: "\n" + type) }
                .joined(separator: " "),
            to: &stream
        )
    }
}

private final class StandardOutputStream: TextOutputStream {
    static var stdout = StandardOutputStream(stream: Darwin.stdout)
    static var stderr = StandardOutputStream(stream: Darwin.stderr)
    
    private let stream: UnsafeMutablePointer<FILE>
    
    private init(stream: UnsafeMutablePointer<FILE>) {
        self.stream = stream
    }
    
    func write(_ string: String) {
        fputs(string, stream)
    }
}
