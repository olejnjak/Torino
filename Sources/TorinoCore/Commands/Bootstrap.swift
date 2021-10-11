import ArgumentParser
import Foundation

struct Bootstrap: ParsableCommand {
    @OptionGroup var args: SharedArguments
    @OptionGroup var carthage: CarthageArguments
    
    func run() throws {
        try Download(args: _args).run()
        try CarthageController().bootstrap(carthage)
        
        if carthage.upload {
            try Upload(args: _args).run()
        }
    }
}
