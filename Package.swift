// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "distributed-storage-poc",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "distributed-storage-poc",
            targets: ["distributed-storage-poc"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "distributed-storage-poc",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "distributed-storage-pocTests",
            dependencies: ["distributed-storage-poc"],
            path: "Tests"
        ),
    ]
)
