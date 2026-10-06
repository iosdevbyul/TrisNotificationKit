// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TrisNotificationKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "TrisNotificationKit",
            targets: ["TrisNotificationKit"]
        )
    ],
    targets: [
        .target(
            name: "TrisNotificationKit"
        ),
        .testTarget(
            name: "TrisNotificationKitTests",
            dependencies: ["TrisNotificationKit"]
        )
    ]
)
