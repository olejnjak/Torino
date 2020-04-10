import Foundation
import TSCBasic
import TSCUtility

public struct CommandRegistry {
    private let argumentParser: ArgumentParser
    
    private let commands: [Command]
    private let arguments: [String]
    
    // MARK: - Initializers
    
    public init() {
        argumentParser = ArgumentParser(commandName: "torino", usage: "<command> <options>", overview: "Cache your Carthage dependencies throughout your team")
        arguments = ProcessInfo.processInfo.arguments
        commands = [
            UploadCommand(parser: argumentParser)
        ]
    }
    
    // MARK: - Public interface
    
    public func run() {
        do {
            let parsedArguments = try parse()
            try process(arguments: parsedArguments)
        } catch {
            print("[ERROR]", error)
        }
    }
    
    // MARK: - Private helpers
    
    /// Returns the command name.
    ///
    /// - Returns: Command name.
    private func commandName() -> String? {
        if arguments.count < 2 { return nil }
        return arguments[1]
    }
    
    private func parse() throws -> ArgumentParser.Result {
        let arguments = Array(self.arguments.dropFirst())
        return try argumentParser.parse(arguments)
    }
    
    private func process(arguments: ArgumentParser.Result) throws {
        guard let subparser = arguments.subparser(argumentParser) else {
            argumentParser.printUsage(on: stdoutStream)
            return
        }
        if let command = commands.first(where: { type(of: $0).name == subparser }) {
            try command.run(with: arguments)
        }
    }
}
