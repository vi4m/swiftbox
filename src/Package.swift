// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "swift_vapor_example",

    products: [
        .executable(name: "swift_vapor_example", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://stash.allegrogroup.com/scm/techappengine/swidamio.git", from: "1.4.2"),
        .package(url: "https://github.com/vapor/leaf-provider.git", from: "1.1.0"),
        .package(url: "https://github.com/vapor/fluent-provider.git", from: "1.3.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["swidamio", "FluentProvider", "LeafProvider"]),
        .target(name: "Run", dependencies: ["App"]),

        .testTarget(
            name: "AppTests",
            dependencies: ["App"]
	)
    ]
)
