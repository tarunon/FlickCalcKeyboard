// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BuildTools",
  platforms: [
    .macOS(.v10_15)
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-format", branch: "0.50500.0")
  ],
  targets: [
    .target(
      name: "BuildTools",
      path: "")
  ]
)
