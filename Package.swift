// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "RouteKit",
  platforms: [.iOS(.v18)],
  products: [
    .library(name: "RouteKit", targets: ["RouteKit"]),
  ],
  targets: [
    .target(name: "RouteKit"),
    .testTarget(name: "RouteKitTests", dependencies: ["RouteKit"]),
  ]
)
