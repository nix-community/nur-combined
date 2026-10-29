// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SeoWebChecker",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "SeoWebChecker",
            targets: ["SeoWebChecker"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SeoWebChecker",
            dependencies: [],
            path: "Sources/SeoWebChecker"
        ),
        .testTarget(
            name: "SeoWebCheckerTests",
            dependencies: ["SeoWebChecker"],
            path: "Tests/SeoWebCheckerTests"
        ),
    ]
)
