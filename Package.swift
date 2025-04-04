// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NnVersionKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "NnVersionKit",
            targets: ["NnVersionKit"]),
    ],
    targets: [
        .target(
            name: "NnVersionKit"),
        .testTarget(
            name: "NnVersionKitTests",
            dependencies: ["NnVersionKit"]
        ),
    ]
)
