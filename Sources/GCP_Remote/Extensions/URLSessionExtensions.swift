import Foundation

struct RequestError: Error {
    let response: URLResponse?
    let data: Data?
}

extension URLSession {
    static let torino = URLSession(configuration: .ephemeral)
    
    @available(*, deprecated, renamed: "data(request:)")
    func syncDataTask(for request: URLRequest) throws -> (Data?, URLResponse?) {
        let semaphore = DispatchSemaphore(value: 0)
        
        var resultData: Data?
        var resultResponse: URLResponse?
        var resultError: Error?
        
        let task = dataTask(with: request) { data, response, error in
            resultData = data
            resultResponse = response
            resultError = error
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        if let error = resultError {
            throw error
        }
        
        if let httpResponse = (resultResponse as? HTTPURLResponse),
           (200...299).contains(httpResponse.statusCode) {
            return (resultData, resultResponse)
        }
        
        throw RequestError(response: resultResponse, data: resultData)
    }
}

// Swift Concurrency API is available from macOS 12,
// to support lower deployment target we need following extensions
@available(macOS, deprecated: 12.0, message: "Use the built-in API instead")
extension URLSession {
    @discardableResult
    func data(request: URLRequest) async throws -> (Data, URLResponse) {
        try await withUnsafeThrowingContinuation { continuation in
            let task = self.dataTask(
                with: request,
                completionHandler: Self.taskCompletion(continuation: continuation)
            )
            
            task.resume()
        }
    }
    
    @discardableResult
    func data(url: URL) async throws -> (Data, URLResponse) {
        try await data(request: URLRequest(url: url))
    }
    
    @discardableResult
    func upload(request: URLRequest, fromFile file: URL) async throws -> (Data, URLResponse) {
        try await withUnsafeThrowingContinuation { continuation in
            let task = self.uploadTask(
                with: request,
                fromFile: file,
                completionHandler: Self.taskCompletion(continuation: continuation)
            )
            
            task.resume()
        }
    }
    
    private static func taskCompletion(continuation: UnsafeContinuation<(Data, URLResponse), Error>) -> (Data?, URLResponse?, Error?) -> () {
        { data, response, error in
            guard let data = data, let response = response else {
                let error = error ?? URLError(.badServerResponse)
                return continuation.resume(throwing: error)
            }
            
            if let httpResponse = (response as? HTTPURLResponse),
               (200...299).contains(httpResponse.statusCode) {
                continuation.resume(returning: (data, response))
            } else {
                continuation.resume(
                    throwing:
                        URLError(
                            .cannotParseResponse,
                            userInfo: [:]
                        )
                )
            }
        }
    }
}
