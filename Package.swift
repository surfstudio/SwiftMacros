// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftMacros",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "SwiftMacros",
            targets: [
                "Macros",
                "SwiftMacrosCore"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [

        // MARK: - Macros

        .target(
            name: "Macros",
            dependencies: [
                "MacrosImplementation",
                "SwiftMacrosCore"
            ],
            path: "Sources/Macros/Macros"
        ),
        .macro(
            name: "MacrosImplementation",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "SwiftMacrosCore",
            ],
            path: "Sources/Macros/MacrosImplementation"
        ),
        .testTarget(
            name: "MacrosTests",
            dependencies: [
                "MacrosImplementation",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),

        // MARK: - SwiftMacrosCore

        .target(
            name: "SwiftMacrosCore",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftMacrosCoreTests",
            dependencies: ["SwiftMacrosCore"]
        ),
    ]
)
