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
            targets: ["BBPSSDK", "BBPSSDKDependencies"]
        )
    ],
    dependencies: [
        .package(name: "HyperSDK", url: "https://github.com/juspay/hypersdk-ios.git", .exact("2.2.4")),
    ],
    targets: [
        .target(
            name: "BBPSSDK",
            path: "Sources/BBPSSDK",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("Constants"),
                .headerSearchPath("Utils"),
                .headerSearchPath("CheckoutLite")
            ]
        ),
        .target(
            name: "BBPSSDKDependencies",
            dependencies: [
                .product(name: "HyperSDK", package: "HyperSDK")
            ]
        )
    ]
)