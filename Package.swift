// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleHabitTracker",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "SimpleHabitTracker", targets: ["SimpleHabitTracker"])
    ],
    targets: [
        .executableTarget(
            name: "SimpleHabitTracker",
            path: "Sources/SimpleHabitTracker"
        )
    ]
)
