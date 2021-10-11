import ArgumentParser
import Foundation

struct Update: ParsableCommand {
    @OptionGroup var args: SharedArguments
    @OptionGroup var carthage: CarthageArguments
    
    func run() throws {
        let carthageController = CarthageController()
        
        try carthageController.update(carthage, noBuild: true)
        try Download(args: _args).run()
        try CarthageController().build(carthage)
        
        if carthage.upload {
            try Upload(args: _args).run()
        }
    }
}
