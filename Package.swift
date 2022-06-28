// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "swiftui-uikit-presenting",
    products: [
        .library(
            name: "UIViewControllerPresenting",
            targets: ["UIViewControllerPresenting"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "UIViewControllerPresenting",
            dependencies: []),
        .testTarget(
            name: "UIViewControllerPresentingTests",
            dependencies: []
        ),
    ]
)
