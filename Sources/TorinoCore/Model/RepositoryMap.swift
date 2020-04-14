import CarthageKit
import Foundation

struct RepositoryMap {
    static let shared = RepositoryMap()
    
    private let mapDictionary: [String: [String]] = [
        "realm-cocoa": ["Realm", "RealmSwift"],
        "mux-stats-sdk-avplayer": ["MUXSDKStats"],
        "stats-sdk-objc": ["MuxCore"],
        "Reachability.swift": ["Reachability"],
        "RxSwift": ["RxBlocking", "RxCocoa", "RxRelay", "RxSwift", "RxTest"],
        "photo-editor": ["iOSPhotoEditor"],
        "nova-plus-player": []
    ]
    
    func frameworkNames(for dependency: Dependency) -> [String] {
        mapDictionary[dependency.name] ?? [dependency.name]
    }
}
