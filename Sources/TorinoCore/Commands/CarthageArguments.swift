import ArgumentParser
import Foundation

struct CarthageArguments: ParsableArguments {
    @Option var platform: String?
}
