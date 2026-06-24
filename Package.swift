// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTML",
    // platforms: [
    //     .macOS(.v13)
    // ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HTML",
            targets: ["HTML"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/DSL.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Milieu.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Methods.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Primitives.git", branch: "master"),
        // .package(url: "https://github.com/leviouwendijk/References.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "HTML",
            dependencies: [
                .product(name: "DSL", package: "DSL"),
                .product(name: "Milieu", package: "Milieu"),
                .product(name: "Methods", package: "Methods"),
                .product(name: "Primitives", package: "Primitives"),
                // .product(name: "References", package: "References"),
            ],
        ),
        .testTarget(
            name: "HTMLTests",
            dependencies: ["HTML"]
        ),
    ]
)
