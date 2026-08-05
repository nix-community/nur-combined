// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "test-swift-differentiation",
    products: [
        .executable(name: "test-swift-differentiation", targets: ["test-swift-differentiation"]),
    ],
    targets: [
        .executableTarget(name: "test-swift-differentiation", path: "Sources")
    ]
)
