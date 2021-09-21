// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "App",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(
      name: "App",
      targets: ["App"]),
    .library(
      name: "CalcKeyboard",
      targets: ["CalcKeyboard"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/tarunon/Builder.git", .branch("main"))
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "App",
      dependencies: ["CalcKeyboard", "CalcHistoryView"]),
    .target(
      name: "FlickButton",
      dependencies: []),
    .target(
      name: "CalcHistoryView",
      dependencies: ["CalcKeyboard"]),
    .target(
      name: "CalcKeyboard",
      dependencies: ["FlickButton", "Builder"]),
    .testTarget(
      name: "AppTests",
      dependencies: ["App"]),
  ]
)
