import Foundation

protocol CarthageControlling {
    func bootstrap(_ args: CarthageArguments) throws
    func update(args: CarthageArguments) throws
}

struct CarthageController: CarthageControlling {
    private let system: Systeming
    
    // MARK: - Initializers
    
    init(system: Systeming = System.shared) {
        self.system = system
    }
    
    // MARK: - Interface
    
    func bootstrap(_ args: CarthageArguments) throws {
        try buildCommand(command: "bootstrap", args: args)
    }
    
    func update(args: CarthageArguments) throws {
        try buildCommand(command: "update", args: args)
    }
    
    // MARK: - Private helpers
    
    private func buildCommand(command: String, args: CarthageArguments) throws {
        var command = [
            "carthage", command, "--cache-builds", "--use-xcframeworks",
        ]
        
        if let platform = args.platform {
            command += ["--platform", platform]
        }
        
        try system.run(command)
    }
}
