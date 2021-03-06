// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "grecon2_experiments",
    platforms: [
        .macOS(.v10_12),
    ],
    dependencies: [
        .package(url: "https://github.com/rvyjidacek/FcaKit.git",  from: "1.2.12"),
        //.package(path: "../FcaKit"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "grecon2_experiments",
            dependencies: ["FcaKit"]),
        .testTarget(
            name: "grecon2_experimentsTests",
            dependencies: ["grecon2_experiments", "FcaKit"]),
    ]
)
