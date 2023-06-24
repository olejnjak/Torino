import ArgumentParser
import Foundation
import Logger
import TSCBasic

struct CleanError: Error {
    let message: String
}

struct Clean: ParsableCommand {
    func run() throws {
        let logger = Logger.shared

        guard let cwd = localFileSystem.currentWorkingDirectory else {
            throw CleanError(message: "Unable to get current working directory")
        }

        let pathProvider = try CarthagePathProvider(
            base: cwd,
            prefix: "" // No need to specify prefix
        )

        try localFileSystem.removeFileTree(pathProvider.cacheDir())

        logger.info("Cache has been cleaned")
    }
}
