// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Torino",
    platforms: [.macOS(.v11)],
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
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.0.1")),
        .package(url: "https://github.com/apple/swift-tools-support-core", .upToNextMajor(from: "0.2.0")),
        .package(url: "https://github.com/vapor/jwt-kit", .upToNextMajor(from: "4.2.6")),
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
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
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
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                .product(name: "JWTKit", package: "jwt-kit")
            ]
        ),
        .target(
            name: "Logger",
            dependencies: [
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
            ]
        ),
    ]
)
