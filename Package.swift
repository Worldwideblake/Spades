// swift-tools-version: 5.9
import PackageDescription

// Note: This Package.swift is provided for syntax checking only.
// To build the actual iOS app, create a new Xcode project (iOS App, SwiftUI)
// and add all files from the Spades/ directory to the project.
let package = Package(
    name: "Spades",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SpadesLib",
            targets: ["SpadesLib"]
        )
    ],
    targets: [
        .target(
            name: "SpadesLib",
            path: "Spades/Spades",
            exclude: [
                "SpadesApp.swift",
                "Assets.xcassets"
            ]
        )
    ]
)
