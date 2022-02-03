// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "grecon2_experiments",
    platforms: [.macOS(.v10_12)],
    dependencies: [
        .package(name: "FcaKit", url: "https://github.com/rvyjidacek/FcaKit.git",  from: "1.2.1"),
    ],
    targets: [
        .executableTarget(
            name: "grecon2_experiments",
            dependencies: ["FcaKit"]),
        .testTarget(
            name: "grecon2_experimentsTests",
            dependencies: ["grecon2_experiments"]),
    ]
)
