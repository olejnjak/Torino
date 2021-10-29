import Foundation
import TSCBasic

protocol Systeming {
    @discardableResult
    func run(_ arguments: [String], cwd: AbsolutePath?, suppressOutput: Bool) throws -> String
}

extension Systeming {
    @discardableResult
    func run(_ arguments: String..., cwd: AbsolutePath? = nil, suppressOutput: Bool = false) throws -> String {
        try run(Array(arguments), cwd: cwd, suppressOutput: suppressOutput)
    }
    
    @discardableResult
    func run(_ arguments: [String]) throws -> String {
        try run(arguments, cwd: nil, suppressOutput: false)
    }
}

struct SystemError: Error {
    let code: Int32
}

struct System: Systeming {
    static let shared = System(logger: Logger.shared)
    
    private init(logger: Logging) {
        self.logger = logger
    }
    
    private let logger: Logging
    
    @discardableResult
    func run(_ args: [String], cwd: AbsolutePath?, suppressOutput: Bool) throws -> String {
        var stdout = ""
        
        let task: TSCBasic.Process = {
            let outputRedirection: TSCBasic.Process.OutputRedirection = .stream(stdout: { output in
                let newOutput = String(decoding: output, as: Unicode.UTF8.self)
                
                stdout += newOutput
                
                if !suppressOutput {
                    logger.logStdout(newOutput)
                }
            }, stderr: { _ in }, redirectStderr: false)
            
            if let cwd = cwd {
                return Process(
                    arguments: args,
                    workingDirectory: cwd,
                    outputRedirection: outputRedirection
                )
            }
            return Process(
                arguments: args,
                outputRedirection: outputRedirection
            )
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
            return stdout
        }
    }
}
