// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NumberFlow",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NumberFlow",
            targets: ["NumberFlow"]
        )
    ],
    targets: [
        .target(
            name: "NumberFlow"
        )
    ]
)
