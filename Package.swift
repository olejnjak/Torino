// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Torino",
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
    ],
    targets: [
        .target(
            name: "Torino",
            dependencies: ["TorinoCore"]),
        .target(
            name: "TorinoCore",
            dependencies: [.product(name: "SwiftToolsSupport", package: "swift-tools-support-core")]),
        .testTarget(
            name: "TorinoCoreTests",
            dependencies: ["TorinoCore"]),
    ]
)
