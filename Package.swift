// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
// -define-availability
let package = Package(
  name: "ObservationSequence",
  platforms: [.macOS("15.0"), .iOS("18.0")],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "ObservationSequence",
      targets: ["ObservationSequence"],
      
    ),

  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "ObservationSequence"
    ),
    .testTarget(name: "Tests", dependencies: ["ObservationSequence"])
    
  ]
)
