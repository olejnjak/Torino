import ArgumentParser

public struct TorinoCore: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "torino",
        subcommands: [
            Upload.self,
            Download.self,
            Clean.self
        ]
    )
    
    public init() {
        
    }
}
