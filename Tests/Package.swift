// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTMLTests",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "htmltest",
            targets: [
                "HTMLTestFlows",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/TestFlows.git", branch: "master"),
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "HTMLTestFlows",
            dependencies: [
                .product(name: "HTML", package: "HTML"),
                .product(
                    name: "TestFlows",
                    package: "TestFlows"
                ),
            ]
        ),
    ]
)
