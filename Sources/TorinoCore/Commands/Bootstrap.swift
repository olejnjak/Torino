import ArgumentParser
import Foundation

struct Bootstrap: ParsableCommand {
    @OptionGroup var args: SharedArguments
    @OptionGroup var carthage: CarthageArguments
    
    func run() throws {
        let download = Download(args: _args)
        
        try download.run()
        try CarthageController().bootstrap(carthage)
        
        if carthage.upload {
            let upload = Upload(args: _args)
            try upload.run()
        }
    }
}
