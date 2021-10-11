import Foundation
import TSCBasic

protocol Systeming {
    func run(_ arguments: [String], cwd: AbsolutePath?) throws
}

extension Systeming {
    func run(_ arguments: String..., cwd: AbsolutePath? = nil) throws {
        try run(Array(arguments), cwd: cwd)
    }
    
    func run(_ arguments: [String]) throws {
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
    
    func run(_ args: [String], cwd: AbsolutePath?) throws {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.currentDirectoryURL = cwd?.asURL
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        
        if task.terminationStatus != 0 {
            throw SystemError(code: task.terminationStatus)
        }
    }
}
