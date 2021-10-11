import Foundation
import TSCBasic

protocol Systeming {
    @discardableResult
    func run(_ arguments: [String], cwd: AbsolutePath?) throws -> String
}

extension Systeming {
    @discardableResult
    func run(_ arguments: String..., cwd: AbsolutePath? = nil) throws -> String {
        try run(Array(arguments), cwd: cwd)
    }
    
    @discardableResult
    func run(_ arguments: [String]) throws -> String {
        try run(arguments, cwd: nil)
    }
}

struct SystemError: Error {
    let code: Int32
}

struct System: Systeming {
    static let shared = System()
    
    private init() {
        
    }
    
    @discardableResult
    func run(_ args: [String], cwd: AbsolutePath?) throws -> String {
        let task: TSCBasic.Process = {
            if let cwd = cwd {
                return Process(
                    arguments: args,
                    workingDirectory: cwd,
                    outputRedirection: .collect
                )
            }
            return Process(arguments: args)
        }()
        
        try task.launch()
        let result = try task.waitUntilExit()
        
        switch result.exitStatus {
        case .signalled(signal: let signal):
            // Don't care about code/signal
            throw SystemError(code: signal)
        case .terminated(code: let code) where code != 0:
            throw SystemError(code: code)
        case .terminated:
            return try result.utf8Output()
        }
    }
}
