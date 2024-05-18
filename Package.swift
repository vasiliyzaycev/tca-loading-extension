// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "tca-loading-extension",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "Loading",
      targets: ["Loading"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.9.3"
    )
  ],
  targets: [
    .target(
      name: "Loading",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      path: "Sources"
    )
  ]
)
