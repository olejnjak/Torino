import Foundation
import GCP_Remote

struct Config: Decodable {
    let gcp: GCPConfig?
}
