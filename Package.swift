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
      type: .static,
      targets: ["App"]),
    .library(
      name: "CalcKeyboard",
      type: .static,
      targets: ["CalcKeyboard"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/apple/swift-numerics", from: "1.0.1"),
    .package(url: "https://github.com/tarunon/Builder", .branch("main"))
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "App",
      dependencies: ["CalcEditorView"]),
    .target(
      name: "Core",
      dependencies: []),
    .target(
      name: "Parsec",
      dependencies: ["Builder"]),
    .target(
      name: "FlickButton",
      dependencies: ["Builder"]),
    .target(
      name: "InputField",
      dependencies: ["Builder", "Core"]),
    .target(
      name: "CalcEditorView",
      dependencies: ["CalcKeyboard"]),
    .target(
      name: "Calculator",
      dependencies: [
        .productItem(name: "Numerics", package: "swift-numerics", condition: .when(platforms: [.iOS])),
        "Parsec"
      ]
    ),
    .target(
      name: "CalcKeyboard",
      dependencies: [
        .productItem(name: "Numerics", package: "swift-numerics", condition: .when(platforms: [.iOS])),
        "Core", "FlickButton", "Calculator", "Builder", "InputField"
      ]),
    .testTarget(
      name: "AppTests",
      dependencies: ["App"]),
    .testTarget(
      name: "CalculatorTests",
      dependencies: ["Calculator"])
  ]
)
