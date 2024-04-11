// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "VSURF-Support",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "SurfMacros",
            targets: ["SurfMacros"]
        ),
        .executable(
            name: "SurfMacrosClient",
            targets: ["SurfMacrosClient"]
        ),
        .library(
            name: "SurfCore",
            targets: ["SurfCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [

        // MARK: - SurfMacros

        .executableTarget(
            name: "SurfMacrosClient",
            dependencies: ["SurfMacros"],
            path: "Sources/SurfMacros/Client"
        ),
        .target(
            name: "SurfMacros",
            dependencies: ["SurfMacroBody"],
            path: "Sources/SurfMacros/Macros"
        ),
        .macro(
            name: "SurfMacroBody",
            dependencies: [
                "SurfMacrosSupport",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/SurfMacros/Implementation"
        ),
        .target(
            name: "SurfMacrosSupport",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/SurfMacros/Support"
        ),
        .testTarget(
            name: "SurfMacrosTests",
            dependencies: [
                "SurfMacroBody",
                "SurfMacrosSupport",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "Tests/SurfMacros"
        ),

        // MARK: - SurfCore

        .target(
            name: "SurfCore",
            dependencies: []
        ),
        .testTarget(
            name: "SurfCoreTests",
            dependencies: ["SurfCore"],
            path: "Tests/SurfCore"
        ),
    ]
)
