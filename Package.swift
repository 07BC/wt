// swift-tools-version: 6.0
//  Package.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import PackageDescription

let package = Package(
    name: "wt",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "wt", targets: ["wt"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0")
    ],
    targets: [
        .executableTarget(
            name: "wt",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "wtTests",
            dependencies: ["wt"]
        )
    ]
)
