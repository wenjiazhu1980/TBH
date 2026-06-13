// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TBH-macOS",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "TBH", targets: ["TBH"])
    ],
    targets: [
        .executableTarget(
            name: "TBH",
            path: "Sources",
            resources: [
                // .copy 保留目录结构，运行时经 Bundle.module 按 "Extracted" 子目录访问
                .copy("Resources/Extracted")
            ]
        ),
        .testTarget(
            name: "TBHTests",
            dependencies: ["TBH"],
            path: "Tests"
        )
    ]
)
