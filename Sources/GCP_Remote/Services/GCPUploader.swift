import Foundation
import Logger
import CryptoKit

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
        
        try await items.asyncForEach {
            let localPath = $0.localFile
            let remotePath = $0.remotePath
            let name = localPath.basenameWithoutExt
            
            logger.info("Uploading dependency", name)
            
            do {
                let existingMetadata: Metadata?
                
                do {
                    let metadata = try await gcpAPI.metadata(
                        object: remotePath,
                        bucket: config.bucket,
                        token: token
                    )
                    existingMetadata = metadata
                    logger.debug(
                        "Existing MD5 for dependency",
                        name,
                        "is",
                        metadata.md5Hash
                    )
                } catch {
                    existingMetadata = nil
                    logger.debug("Unable to fetch existing metadata")
                    logger.debug(error)
                }
                
                if let currentMD5 = existingMetadata?.md5Hash,
                    let data = try? Data(contentsOf: localPath.asURL) {
                    let md5 = Data(Insecure.MD5.hash(data: data))
                        .base64EncodedString()
                    
                    logger.debug("Comparing MD5 hash for dependendency", name)
                    logger.debug("Local:", md5, "Remote:", currentMD5)
                    
                    if currentMD5 == md5 {
                        logger.info("Dependency " + name + " has not changed, skipping upload")
                        return
                    }
                }
                
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
                throw error
            }
        }
    }
}
