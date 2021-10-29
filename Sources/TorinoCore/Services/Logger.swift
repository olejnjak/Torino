import Foundation

protocol Logging {
    func logStdout(_ output: String...)
    func info(_ info: String...)
}

struct Logger: Logging {
    static let shared = Logger()
    
    private init() {
        
    }
    
    func logStdout(_ output: String...) {
        print("[OUTPUT]", output)
    }
    
    func info(_ info: String...) {
        print("[INFO]", info)
    }
}
