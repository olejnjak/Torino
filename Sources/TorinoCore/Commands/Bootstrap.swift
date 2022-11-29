import ArgumentParser
import Foundation
import Logger
import TSCBasic

struct Bootstrap: ParsableCommand {
    @OptionGroup var args: SharedArguments
    @OptionGroup var carthage: CarthageArguments
    
    func run() throws {
        if let cwd = localFileSystem.currentWorkingDirectory {
            let logger = Logger.shared
            let prefix = try args.prefix ?? AutoPrefixService().autoPrefix()
            let pathProvider = try CarthagePathProvider(
                base: cwd,
                prefix: prefix
            )
            
            let lockfilePath = pathProvider.lockfile()
            
            guard localFileSystem.exists(lockfilePath) else {
                logger.info("No Cartfile.resolved found at '\(lockfilePath)', finishing early")
                return
            }
        }
        
        try Download(args: _args).run()
        try CarthageController().bootstrap(carthage)
        
        if carthage.upload {
            try Upload(args: _args).run()
        }
    }
}
