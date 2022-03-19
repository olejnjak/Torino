import Foundation
import TSCBasic
import Logger

public typealias UploadItem = (localFile: AbsolutePath, remotePath: String)

public protocol GCPUploading {
    func upload(items: [UploadItem]) async throws
}

public struct GCPUploader: GCPUploading {
    private let authAPI: AuthAPIServicing
    private let gcpAPI: GCPAPIServicing
    private let logger: Logging
    private let config: GCPConfig
    
    // MARK: - Initializers
    
    public init(
        authAPI: AuthAPIServicing = AuthAPIService(),
        gcpAPI: GCPAPIServicing = GCPAPIService(),
        logger: Logging = Logger.shared,
        config: GCPConfig
    ) {
        self.authAPI = authAPI
        self.gcpAPI = gcpAPI
        self.logger = logger
        self.config = config
    }
    
    // MARK: - Public nterface
    
    public func upload(items: [UploadItem]) async throws {
        guard items.count > 0 else {
            logger.info("Nothing to upload")
            return
        }
        
        let sa = try loadServiceAccount(path: config.serviceAccountPath)
        let token = try await authAPI.fetchAccessToken(
            serviceAccount: sa,
            validFor: 60,
            readOnly: false
        )
        
        try await items.asyncForEach { localPath, remotePath in
            let name = localPath.basenameWithoutExt
            
            logger.info("Uploading dependency", name)
            
            var urlComponents = URLComponents(string: "https://storage.googleapis.com/upload/storage/v1/b/" + config.bucket + "/o")!
            urlComponents.queryItems = [
                .init(name: "uploadType", value: "media"),
                .init(name: "name", value: remotePath),
            ]
            
            var request = URLRequest(url: urlComponents.url!)
            token.addToRequest(&request)
            request.setValue("application/zip", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            do {
                request.httpBody = try Data(contentsOf: localPath.asURL)
                
                try await gcpAPI.upload(
                    file: localPath.asURL,
                    object: remotePath,
                    bucket: config.bucket,
                    token: token
                )
                logger.info("Successfully uploaded dependency", name)
            } catch {
                logger.info("Unable to upload dependency", name)
                logger.error(error.localizedDescription)
            }
        }
    }
}
