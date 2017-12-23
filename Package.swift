// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "add_all_carthage",
    products: [
        .executable(name: "add_all_carthage", targets: ["add_all_carthage"]),
        ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(url: "https://github.com/xcodeswift/xcproj.git", .upToNextMajor(from: "0.2.0")),
        .package(url: "https://github.com/iOSleep/CommandLine/", .branch("swift4-default")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "add_all_carthage",
            dependencies: ["Rainbow", "CommandLine", "xcproj"]),
    ]
)
