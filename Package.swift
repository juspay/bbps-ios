// swift-tools-version:5.3
// Version: 0.0.7 (keep in sync with VERSION file)
import PackageDescription

let package = Package(
    name: "BBPSSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BBPSSDK",
            targets: ["BBPSSDK"]
        )
    ],
    dependencies: [
        .package(name: "HyperSDK", url: "https://github.com/juspay/hypersdk-ios.git", .exact("2.2.8")),
    ],
    targets: [
        .target(
            name: "BBPSSDK",
            dependencies: [
                .product(name: "HyperSDK", package: "HyperSDK")
            ],
            path: "Sources/BBPSSDK",
            publicHeadersPath: "."
        )
    ]
)
