import Foundation
import TSCUtility

internal protocol Command {
    /// Name of command
    static var name: String { get }
    
    init(parser: ArgumentParser)
    
    /// Runs command with given arguments
    func run(with arguments: ArgumentParser.Result) throws
}
