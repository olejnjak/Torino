import Foundation

struct RequestError: Error {
    let response: URLResponse?
    let data: Data?
}

extension URLSession {
    static let torino = URLSession(configuration: .ephemeral)
}
