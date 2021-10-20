import ArgumentParser

public struct TorinoCore: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "torino",
        subcommands: [
            Upload.self,
            Download.self,
            Bootstrap.self,
            Update.self
        ]
    )
    
    public init() {
        
    }
}
