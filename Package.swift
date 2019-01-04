// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "hws_vapor_meme_machine",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMinor(from: "3.1.0")),
        .package(url: "https://github.com/vapor/leaf.git", .upToNextMinor(from: "3.0.0")),
        .package(url: "https://github.com/twostraws/SwiftGD.git", .upToNextMinor(from: "2.2.0")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", "SwiftGD"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

