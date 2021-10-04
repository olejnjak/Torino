// swift-tools-version:5.4
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
        .package(url: "https://github.com/apple/swift-argument-parser", .branch("main")),
        .package(url: "https://github.com/apple/swift-tools-support-core", .upToNextMajor(from: "0.2.0")),
    ],
    targets: [
        .executableTarget(
            name: "Torino",
            dependencies: ["TorinoCore"]
        ),
        .target(
            name: "TorinoCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
            ]
        ),
        .testTarget(
            name: "TorinoCoreTests",
            dependencies: ["TorinoCore"]
        ),
    ]
)
