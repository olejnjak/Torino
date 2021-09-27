import ArgumentParser

public struct TorinoCore: ParsableCommand {
    public static var configuration = CommandConfiguration(
        subcommands: [Upload.self, Download.self]
    )
    
    public init() {
        
    }
}
