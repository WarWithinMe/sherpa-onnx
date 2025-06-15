// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SenseVoiceSwift",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        // Add the ONNX runtime package dependency
        .package(url: "https://github.com/microsoft/onnxruntime-swift-package-manager.git", .upToNextMajor(from: "1.7.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "SenseVoiceSwift",
            dependencies: [
                // Add onnxruntime-swift as a dependency for the main target
                .product(name: "onnxruntime-swift", package: "onnxruntime-swift-package-manager")
            ]
        ),
        .testTarget(
            name: "SenseVoiceSwiftTests",
            dependencies: ["SenseVoiceSwift"]),
    ]
)
