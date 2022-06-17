// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VaporDSL",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "VaporDSL", targets: ["VaporDSL"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(name: "VaporDSL",  dependencies: [
            .product(name: "Vapor", package: "vapor"),
        ]),
        .testTarget(name: "VaporDSLTests", dependencies: [
            "VaporDSL"
        ]),
    ]
)
