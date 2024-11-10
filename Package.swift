// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Torino",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "torino",
            targets: ["Torino"]
        ),
        .library(
            name: "TorinoCore",
            targets: ["TorinoCore"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.0.1"
        ),
        .package(
            url: "https://github.com/apple/swift-tools-support-core",
            from: "0.2.0"
        ),
        .package(
            url: "https://github.com/olejnjak/google-auth-swift",
            from: "0.1.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "Torino",
            dependencies: ["TorinoCore"]
        ),
        .target(
            name: "TorinoCore",
            dependencies: [
                "GCP_Remote",
                "Logger",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .product(
                    name: "SwiftToolsSupport-auto",
                    package: "swift-tools-support-core"
                ),
            ]
        ),
        .testTarget(
            name: "TorinoCoreTests",
            dependencies: ["TorinoCore"]
        ),
        .target(
            name: "GCP_Remote",
            dependencies: [
                "Logger",
                .product(
                    name: "SwiftToolsSupport-auto",
                    package: "swift-tools-support-core"
                ),
                .product(
                    name: "GoogleAuth",
                    package: "google-auth-swift"
                )
            ]
        ),
        .target(
            name: "Logger",
            dependencies: [
                .product(
                    name: "SwiftToolsSupport-auto",
                    package: "swift-tools-support-core"
                ),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
