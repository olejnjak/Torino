import Foundation

struct RequestError: Error {
    let response: URLResponse?
    let data: Data?
}

extension URLSession {
    static let torino = URLSession(configuration: .ephemeral)
    
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
