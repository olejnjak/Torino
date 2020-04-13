// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Torino",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(
            name: "torino",
            targets: ["Torino"]),
        .library(
            name: "TorinoCore",
            targets: ["TorinoCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-tools-support-core", .upToNextMajor(from: "0.1.0")),
//        .package(url: "https://github.com/Carthage/Carthage", .branch("master")),
        .package(url: "https://github.com/olejnjak/Carthage", .branch("publish_version_functions")),
        .package(url: "https://github.com/tuist/tuist", .branch("master")),
    ],
    targets: [
        .target(
            name: "Torino",
            dependencies: ["TorinoCore"]),
        .target(
            name: "TorinoCore",
            dependencies: [
                .product(name: "SwiftToolsSupport", package: "swift-tools-support-core"),
                .product(name: "CarthageKit", package: "Carthage"),
                .product(name: "XCDBLD", package: "Carthage"),
                .product(name: "TuistGenerator", package: "tuist"),
        ]),
        .testTarget(
            name: "TorinoCoreTests",
            dependencies: ["TorinoCore"]),
    ]
)
