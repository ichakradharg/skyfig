// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SkyfigPackageConsumer",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(path: "../.."),
    ],
    targets: [
        .executableTarget(
            name: "SkyfigPackageConsumer",
            dependencies: [
                .product(name: "Skyfig", package: "Skyfig"),
            ]
        ),
    ]
)
