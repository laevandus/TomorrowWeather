// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TomorrowWeather",
    platforms: [
        .iOS(.v17),
        // TODO: Add more platforms when everything works on iOS
    ],
    products: [
        .library(
            name: "TomorrowWeather",
            targets: ["TomorrowWeather"]
        ),
    ],
    targets: [
        // Public
        .target(
            name: "TomorrowWeather",
            dependencies: ["Networking"]
        ),
        .testTarget(
            name: "TomorrowWeatherTests",
            dependencies: ["TomorrowWeather"]
        ),
        // Internal
        .target(
            name: "Networking"
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]
        ),
    ]
)
