import ArgumentParser
import Foundation

struct Bootstrap: ParsableCommand {
    @OptionGroup var args: SharedArguments
    @OptionGroup var carthage: CarthageArguments
    
    func run() throws {
        
    }
}
