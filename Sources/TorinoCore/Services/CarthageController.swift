import Foundation

protocol CarthageControlling {
    func build(_ args: CarthageArguments) throws
    func bootstrap(_ args: CarthageArguments) throws
    func update(_ args: CarthageArguments, noBuild: Bool) throws
}

struct CarthageController: CarthageControlling {
    private let system: Systeming
    
    // MARK: - Initializers
    
    init(system: Systeming = System.shared) {
        self.system = system
    }
    
    // MARK: - Interface
    
    func bootstrap(_ args: CarthageArguments) throws {
        try buildUsing(command: "bootstrap", args: args)
    }
    
    func update(_ args: CarthageArguments, noBuild: Bool) throws {
        if noBuild {
            try system.run("carthage", "update", "--no-build")
        } else {
            try buildUsing(command: "update", args: args)
        }
    }
    
    func build(_ args: CarthageArguments) throws {
        try buildUsing(command: "build", args: args)
    }
    
    // MARK: - Private helpers
    
    private func buildUsing(command: String, args: CarthageArguments) throws {
        var command = [
            "carthage", command, "--cache-builds", "--use-xcframeworks",
        ]
        
        if let platform = args.platform {
            command += ["--platform", platform]
        }
        
        try system.run(command)
    }
}
