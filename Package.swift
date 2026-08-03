// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Skyfig",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "Skyfig", targets: ["Skyfig"]),
        .executable(name: "skyfig", targets: ["SkyfigCLI"]),
        .executable(name: "SkyfigShowcase", targets: ["SkyfigShowcase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.5.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.0"),
    ],
    targets: [
        .target(name: "Skyfig"),
        .target(name: "SkyfigGenerator"),
        .executableTarget(
            name: "SkyfigCLI",
            dependencies: ["SkyfigGenerator"]
        ),
        .executableTarget(
            name: "SkyfigShowcase",
            dependencies: ["Skyfig"],
            path: "Examples/SkyfigShowcase"
        ),
        .testTarget(
            name: "SkyfigGeneratorTests",
            dependencies: ["SkyfigGenerator"],
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "SkyfigTests",
            dependencies: ["Skyfig"]
        ),
    ]
)
