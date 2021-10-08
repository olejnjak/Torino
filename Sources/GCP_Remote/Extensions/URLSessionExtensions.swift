import Foundation

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
        
        return (resultData, resultResponse)
    }
}
