import ArgumentParser
import Foundation

struct CarthageArguments: ParsableArguments {
    @Option var platform: String?
    @Flag var upload = false
}
