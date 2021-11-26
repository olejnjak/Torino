import Foundation
import TSCUtility

public protocol Logging {
    func logStdout(_ output: String...)
    func info(_ info: String...)
    func error(_ error: String...)
}

public struct Logger: Logging {
    public static let shared = Logger()
    
    private init() {
        
    }
    
    public func logStdout(_ output: String...) {
        print(type: "[OUTPUT]", output: output, to: &StandardOutputStream.stdout)
    }
    
    public func info(_ info: String...) {
        print(type: "[INFO]", output: info, to: &StandardOutputStream.stdout)
    }
    
    public func error(_ error: String...) {
        print(type: "[ERROR]", output: error, to: &StandardOutputStream.stderr)
    }
    
    private func print<Stream: TextOutputStream>(type: String, output: [String], to stream: inout Stream) {
        Swift.print(
            type,
            output.map { $0.trimmingCharacters(in: .newlines).replacingOccurrences(of: "\n", with: "\n" + type + " ") }
                .joined(separator: " "),
            to: &stream
        )
    }
}

private final class StandardOutputStream: TextOutputStream {
    static var stdout = StandardOutputStream(stream: FileHandle.standardOutput)
    static var stderr = StandardOutputStream(stream: FileHandle.standardError)

    private let stream: FileHandle

    private init(stream: FileHandle) {
        self.stream = stream
    }

    func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        stream.write(data)
    }
}
