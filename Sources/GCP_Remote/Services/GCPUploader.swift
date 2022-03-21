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
            let localHash = $0.hash
            let name = localPath.basenameWithoutExt
            
            logger.info("Uploading dependency", name)
            
            do {
                let remoteHash: String?
                
                do {
                    remoteHash = try await gcpAPI.metadata(
                        object: remotePath,
                        bucket: config.bucket,
                        token: token
                    ).metadata?.carthageHash
                } catch {
                    remoteHash = nil
                    logger.debug("Unable to fetch existing metadata")
                    logger.debug(error)
                }
                
                if let currentHash = remoteHash {
                    logger.debug("Comparing hash for dependendency", name)
                    logger.debug("Local:", localHash, "Remote:", remoteHash ?? "(nil)")
                    
                    if currentHash == localHash {
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
                
                try await gcpAPI.updateMetadata(
                    .init(metadata: .init(carthageHash: localHash)),
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
