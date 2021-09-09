import ArgumentParser
import TSCBasic

struct UploadError: Error {
    let message: String
}

struct Upload: ParsableCommand {
    func run() throws {
        guard let cwd = localFileSystem.currentWorkingDirectory else {
            throw UploadError(message: "Unable to get current working directory")
        }
        
        try UploadService().run(path: cwd)
    }
}
