// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TKRubberPageControl",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "TKRubberPageControl",
            targets: ["TKRubberPageControl"]
        )
    ],
    targets: [
        .target(
            name: "TKRubberPageControl",
            path: "Sources/TKRubberPageControl"
        ),
        .testTarget(
            name: "TKRubberPageControlTests",
            dependencies: ["TKRubberPageControl"],
            path: "Tests/TKRubberPageControlTests"
        ),
    ],
    swiftLanguageModes: [.v5]
)
