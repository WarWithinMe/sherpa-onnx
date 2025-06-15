// swift-tools-version: 5.10
import PackageDescription
let package = Package(
    name: "SenseVoiceSwift",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/microsoft/onnxruntime-swift-package-manager.git", .upToNextMajor(from: "1.7.0"))
    ],
    targets: [
        .executableTarget(
            name: "SenseVoiceSwift",
            dependencies: [.product(name: "onnxruntime-swift", package: "onnxruntime-swift-package-manager")],
            path: "Sources"
        ),
        .testTarget(
            name: "SenseVoiceSwiftTests",
            dependencies: ["SenseVoiceSwift"],
            path: "Tests/SenseVoiceSwiftTests"
        ),
    ]
)
