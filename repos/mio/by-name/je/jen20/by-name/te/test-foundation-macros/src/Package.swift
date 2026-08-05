// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "test-foundation-macros",
    platforms: [ .macOS("14.0") ],
    products: [
        .executable(name: "test-foundation-macros", targets: ["test-foundation-macros"]),
    ],
    targets: [
        .executableTarget(name: "test-foundation-macros", path: "Sources")
    ]
)
