// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "BBPSSDK",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "BBPSSDK",
            targets: ["BBPSSDK"]
        )
    ],
    dependencies: [
        .package(name: "HyperSDK", url: "https://github.com/juspay/hypersdk-ios.git", .exact("2.2.4")),
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