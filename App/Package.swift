// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "App",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(
      name: "App",
      type: .static,
      targets: ["App"]
    ),
    .library(
      name: "KeyboardExtension",
      type: .static,
      targets: ["KeyboardExtension"]
    ),
    .library(
      name: "Preview",
      type: .dynamic,
      targets: ["CalcEditorView", "CalcKeyboard", "FlickButton", "InputField"]
    ),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/apple/swift-numerics", from: "1.0.1"),
    .package(url: "https://github.com/tarunon/Builder", .branch("main")),
  ],
  targets: .tree(
    .directory(
      name: "Sources",
      [
        .target(
          name: "App",
          dependencies: ["CalcEditorView"]
        ),
        .directory(
          name: "Components",
          [
            .target(
              name: "CalcEditorView",
              dependencies: [
                "CalcKeyboard",
                "Core",
              ]
            ),
            .target(
              name: "CalcKeyboard",
              dependencies: [
                "Bundles",
                "Core",
                "CalcMemory",
                "Calculator",
                "FlickButton",
                "InputField",
                "InputControl",
                .productItem(
                  name: "Numerics",
                  package: "swift-numerics",
                  condition: .when(platforms: [.iOS])
                ),
              ]
            ),
            .target(
              name: "FlickButton",
              dependencies: [
                "Bundles",
                "Core",
              ]
            ),
            .target(
              name: "InputField",
              dependencies: [
                "Core"
              ]
            ),
          ]
        ),
        .directory(
          name: "Core",
          [
            .target(
              name: "Bundles"
            ),
            .target(
              name: "Core",
              dependencies: [
                "Builder"
              ]
            ),
            .target(
              name: "Parsec",
              dependencies: [
                "Core"
              ]
            ),
          ]
        ),
        .target(
          name: "KeyboardExtension",
          dependencies: [
            "CalcKeyboard"
          ]
        ),
        .directory(
          name: "Services",
          [
            .target(
              name: "CalcMemory",
              dependencies: [
                "Calculator",
                .productItem(
                  name: "Numerics",
                  package: "swift-numerics",
                  condition: .when(platforms: [.iOS])
                ),
              ]
            ),
            .target(
              name: "Calculator",
              dependencies: [
                "Core",
                "Parsec",
                .productItem(
                  name: "Numerics",
                  package: "swift-numerics",
                  condition: .when(platforms: [.iOS])
                ),
              ]
            ),
            .target(
              name: "InputControl",
              dependencies: [
                "Core",
                "Bundles",
                "Calculator",
              ]
            ),
          ]
        ),
      ]
    ),
    .directory(
      name: "Tests",
      [
        .testTarget(
          name: "AppTests",
          dependencies: ["App"]
        ),
        .testTarget(
          name: "CalculatorTests",
          dependencies: ["Calculator"]
        ),
        .testTarget(
          name: "ParsecTests",
          dependencies: ["Parsec"]
        ),
        .testTarget(
          name: "InputControlTests",
          dependencies: ["InputControl"]
        ),
      ]
    )
  )
)

indirect enum DirectoryTree {
  case directory(name: String, _ children: [DirectoryTree])
  case target(Target)

  static func target(
    name: String,
    dependencies: [Target.Dependency] = [],
    path: String? = nil,
    exclude: [String] = [],
    sources: [String]? = nil,
    resources: [Resource]? = nil,
    publicHeadersPath: String? = nil,
    cSettings: [CSetting]? = nil,
    cxxSettings: [CXXSetting]? = nil,
    swiftSettings: [SwiftSetting]? = nil,
    linkerSettings: [LinkerSetting]? = nil,
    plugins: [Target.PluginUsage]? = nil
  ) -> DirectoryTree {
    .target(
      .target(
        name: name,
        dependencies: dependencies,
        path: path,
        exclude: exclude,
        sources: sources,
        resources: resources,
        publicHeadersPath: publicHeadersPath,
        cSettings: cSettings,
        cxxSettings: cxxSettings,
        swiftSettings: swiftSettings,
        linkerSettings: linkerSettings,
        plugins: plugins
      )
    )
  }

  static func testTarget(
    name: String,
    dependencies: [Target.Dependency] = [],
    path: String? = nil,
    exclude: [String] = [],
    sources: [String]? = nil,
    resources: [Resource]? = nil,
    cSettings: [CSetting]? = nil,
    cxxSettings: [CXXSetting]? = nil,
    swiftSettings: [SwiftSetting]? = nil,
    linkerSettings: [LinkerSetting]? = nil,
    plugins: [Target.PluginUsage]? = nil
  ) -> DirectoryTree {
    .target(
      .testTarget(
        name: name,
        dependencies: dependencies,
        path: path,
        exclude: exclude,
        sources: sources,
        resources: resources,
        cSettings: cSettings,
        cxxSettings: cxxSettings,
        swiftSettings: swiftSettings,
        linkerSettings: linkerSettings,
        plugins: plugins
      )
    )
  }

  func targets() -> [Target] {
    switch self {
    case .directory(let name, let children):
      return children.flatMap { sourceTree -> [Target] in
        let targets = sourceTree.targets()
        targets.forEach { $0.path = name + "/" + $0.path! }
        return targets
      }
    case .target(let target):
      target.path = target.name
      return [target]
    }
  }
}

extension Array where Element == Target {
  static func tree(_ trees: DirectoryTree...) -> [Target] {
    trees.flatMap { $0.targets() }
  }
}
