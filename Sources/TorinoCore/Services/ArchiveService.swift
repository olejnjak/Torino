import Foundation
import TSCBasic

protocol ArchiveServicing {
    func archive(files: [RelativePath], basePath: AbsolutePath, destination: AbsolutePath) throws
    func unarchive(from path: AbsolutePath, destination: AbsolutePath) throws
}

final class ZipService: ArchiveServicing {
    private let system: Systeming
    
    // MARK: - Initializers
    
    init(system: Systeming) {
        self.system = system
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
        } catch let error as SystemError {
            if error.code != 12 { // zip has nothing to do
                throw error
            }
        }
    }
    
    func unarchive(from path: AbsolutePath, destination: AbsolutePath) throws {
        try shell(["unzip", "-oqq", path.pathString], cwd: destination)
    }
    
    // MARK: - Private helpers

    private func shell(_ args: [String], cwd: AbsolutePath? = nil) throws {
        try system.run(args, cwd: cwd, suppressOutput: true)
    }
}
