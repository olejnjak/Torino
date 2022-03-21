import Foundation
import TSCUtility

public protocol Logging {
    func logStdout(_ output: CustomStringConvertible...)
    func info(_ info: CustomStringConvertible...)
    func error(_ error: CustomStringConvertible...)
    func debug(_ info: CustomDebugStringConvertible...)
}

public extension Logging {
    func error(_ error: Error) {
        self.error(error as NSError)
    }
    
    func debug(_ error: Error) {
        debug(error as NSError)
    }
}

public struct Logger: Logging {
    public enum LogLevel: String, Comparable, Equatable, CaseIterable {
        case debug, info
        
        public static func < (lhs: Logger.LogLevel, rhs: Logger.LogLevel) -> Bool {
            allCases.firstIndex(of: lhs)! > allCases.firstIndex(of: rhs)!
        }
    }
    
    public static let shared = Logger(
        logLevel: ProcessInfo.processInfo.environment["TORINO_LOG_LEVEL"]
            .flatMap(LogLevel.init) ?? .info
    )
    
    private let logLevel: LogLevel
    
    private init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }
    
    public func logStdout(_ output: CustomStringConvertible...) {
        print(type: "[OUTPUT]", output: output, to: &StandardOutputStream.stdout)
    }
    
    public func info(_ info: CustomStringConvertible...) {
        print(type: "[INFO]", output: info, to: &StandardOutputStream.stdout)
    }
    
    public func error(_ error: CustomStringConvertible...) {
        print(type: "[ERROR]", output: error, to: &StandardOutputStream.stderr)
    }
    
    public func debug(_ info: CustomDebugStringConvertible...) {
        if logLevel >= .debug {
            print(type: "[DEBUG]", output: info.map(\.debugDescription), to: &StandardOutputStream.stdout)
        }
    }
    
    private func print<Stream: TextOutputStream>(type: String, output: [CustomStringConvertible], to stream: inout Stream) {
        Swift.print(
            type,
            output.map { "\($0)".trimmingCharacters(in: .newlines).replacingOccurrences(of: "\n", with: "\n" + type + " ") }
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
