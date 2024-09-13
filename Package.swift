// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BottomSheet",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "BottomSheet", targets: ["BottomSheet"]),
    ],
    targets: [
        .target(
            name: "BottomSheet"
        ),
    ]
)
