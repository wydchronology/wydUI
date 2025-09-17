// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "wydUI",
    platforms: [
        .iOS(.v26) // Specify the minimum iOS version here
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "wydUI",
            targets: ["wydUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "26.0.0"),
        .package(url: "https://github.com/davedelong/time", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "wydUI",
            dependencies: [
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
                .product(name: "Time", package: "time"),
            ]
        ),
    ],
)
