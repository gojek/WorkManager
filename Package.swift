// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "WorkManager",
    platforms: [.iOS(.v12),
                .macOS(.v12),
                .watchOS(.v4),
                .tvOS(.v11)],
    products: [
        .library(
            name: "WorkManager",
            targets: ["WorkManager"]),
    ],
    targets: [
        .target(
            name: "WorkManager",
            dependencies: []),
        .testTarget(
            name: "WorkManagerTests",
            dependencies: ["WorkManager"]),
    ]
)
