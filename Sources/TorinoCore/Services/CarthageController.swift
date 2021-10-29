import Foundation

protocol CarthageControlling {
    func build(_ args: CarthageArguments) throws
    func bootstrap(_ args: CarthageArguments) throws
    func update(_ args: CarthageArguments, noBuild: Bool) throws
}

struct CarthageController: CarthageControlling {
    private let system: Systeming
    private let logger: Logging
    
    // MARK: - Initializers
    
    init(
        system: Systeming = System.shared,
        logger: Logging = Logger.shared
    ) {
        self.system = system
        self.logger = logger
    }
    
    // MARK: - Interface
    
    func bootstrap(_ args: CarthageArguments) throws {
        try buildUsing(command: "bootstrap", args: args)
    }
    
    func update(_ args: CarthageArguments, noBuild: Bool) throws {
        if noBuild {
            logger.info("Updating Carthage dependencies without building")
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
        
        logger.info("Running `\(command.joined(separator: " "))`")
        try system.run(command)
    }
}
