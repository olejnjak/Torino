import Foundation
import TSCUtility

internal struct UploadCommand: Command {
    static var name: String { "upload" }
    
    // MARK: - Initializers
    
    init(parser: ArgumentParser) {
        // Subparser will be used later
        _ = parser.add(subparser: "upload", overview: "Uploads dependencies to shared storage")
    }
    
    // MARK: - Public interface
    
    func run(with arguments: ArgumentParser.Result) throws {
        
    }
}
