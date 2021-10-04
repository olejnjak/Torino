import Foundation
import TSCBasic

protocol ArchiveServicing {
    func archive(files: [RelativePath], basePath: AbsolutePath, destination: AbsolutePath) throws
    func unarchive(from path: AbsolutePath, destination: AbsolutePath) throws
}

final class ZipService: ArchiveServicing {
    private struct ShellError: Error {
        let code: Int32
    }
    
    // MARK: - Public interface
    
    func archive(files: [RelativePath], basePath: AbsolutePath, destination: AbsolutePath) throws {
        do {
            try shell(
                [
                    "zip", "-ruq",
                    destination.pathString,
                ] + files.map(\.pathString),
                cwd: basePath
            )
        } catch let error as ShellError {
            if error.code != 12 { // zip has nothing to do
                throw error
            }
        }
    }
    
    func unarchive(from path: AbsolutePath, destination: AbsolutePath) throws {
        try shell(["unzip", "-ouqq", path.pathString], cwd: destination)
    }
    
    // MARK: - Private helpers

    private func shell(_ args: [String], cwd: AbsolutePath? = nil) throws {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.currentDirectoryURL = cwd?.asURL
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        
        if task.terminationStatus != 0 {
            throw ShellError(code: task.terminationStatus)
        }
    }

}
