// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "ForgeObservers",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "ForgeObservers",
            targets: ["ForgeObservers"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ForgeObservers",
            dependencies: []
        ),
        .testTarget(
            name: "ForgeObserversTests",
            dependencies: ["ForgeObservers"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
