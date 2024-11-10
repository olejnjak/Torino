import Foundation
import GoogleAuth

extension Token {
    func addToRequest(_ request: inout URLRequest) {
        request.setValue(tokenType + " " + accessToken, forHTTPHeaderField: "Authorization")
    }
}
