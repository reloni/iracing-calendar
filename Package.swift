// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Hello",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .exact("4.45.2")),
        .package(url: "https://github.com/vapor/leaf", .exact("4.1.2")),
        .package(url: "https://github.com/vapor-community/Imperial.git", .exact("1.1.0"))
    ],
    targets: [
        .target(
            name: "Frontend",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "ImperialGoogle", package: "Imperial")
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        // .target(name: "Run", dependencies: [.target(name: "App")]),
        // .testTarget(name: "AppTests", dependencies: [
        //     .target(name: "App"),
        //     .product(name: "XCTVapor", package: "vapor"),
        // ])
    ]
)
