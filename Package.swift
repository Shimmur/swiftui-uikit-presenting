// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "swiftui-uikit-presenting",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "UIViewControllerPresenting",
            targets: ["UIViewControllerPresenting"]
        ),
        .library(
            name: "SafariWebView",
            targets: ["SafariWebView"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "UIViewControllerPresenting",
            dependencies: []
        ),
        .testTarget(
            name: "UIViewControllerPresentingTests",
            dependencies: ["UIViewControllerPresenting"]
        ),

        // MARK: - Example Libraries

        .target(
            name: "SafariWebView",
            dependencies: ["UIViewControllerPresenting"]
        ),
    ]
)
