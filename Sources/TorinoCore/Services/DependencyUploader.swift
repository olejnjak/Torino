import CarthageKit
import ReactiveSwift

/// Protocol wrapping dependecy upload service
public protocol DependencyUploading {
    /// Upload all dependencies from given `cartfile` and `project` to cache
    func upload(_ cartfile: ResolvedCartfile, from project: Project) -> SignalProducer<Void, TorinoError>
}

final class DependencyUploader: DependencyUploading {
    func upload(_ cartfile: ResolvedCartfile, from project: Project) -> SignalProducer<Void, TorinoError> {
        .never
    }
}
