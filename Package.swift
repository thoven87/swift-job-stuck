// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
]

let package = Package(
    name: "swift-job-stuck",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", branch: "main"),
        .package(url: "https://github.com/hummingbird-project/swift-jobs.git", branch: "main"),
        .package(
            url: "https://github.com/hummingbird-project/swift-jobs-redis.git", branch: "main"),
        .package(
            url: "https://github.com/hummingbird-project/hummingbird-redis.git", branch: "main"),
        .package(url: "https://github.com/joannis/SMTPKitten.git", from: "0.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "SwiftJobStuck",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HummingbirdRouter", package: "hummingbird"),
                .product(name: "HummingbirdRedis", package: "hummingbird-redis"),
                .product(name: "Jobs", package: "swift-jobs"),
                .product(name: "JobsRedis", package: "swift-jobs-redis"),
                .product(name: "SMTPKitten", package: "SMTPKitten"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)
