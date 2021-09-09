import ArgumentParser

public struct TorinoCore: ParsableCommand {
    public static var configuration = CommandConfiguration(
        subcommands: [Upload.self],
        defaultSubcommand: Upload.self
    )
    
    public init() {
        
    }
}
