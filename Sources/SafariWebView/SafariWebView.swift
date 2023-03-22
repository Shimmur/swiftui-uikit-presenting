#if canImport(UIKit)
import SafariServices
import SwiftUI
import UIViewControllerPresenting

public extension View {
    /// Opens the specified URL, using `SFSafariViewController`.
    ///
    /// You can use this modifier in a SwiftUI view to attach Safari browsing functionality to
    /// a view and control the presentation with a binding.
    ///
    /// - Parameters:
    ///    - url: The URL to open in the Safari view.
    ///    - configuration: An optional configuration for the Safari view controller.
    ///    - isPresented: A binding to the state used to drive presentation of this view.
    ///    - animated: Controls whether or not the presentation is animated.
    ///
    func safariWebView(
        url: URL,
        configuration: SFSafariViewController.Configuration? = nil,
        isPresented: Binding<Bool>,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
        animated: Bool = true
    ) -> some View {
        background(
            UIViewControllerPresenting.safariViewController(
                url: url,
                configuration: configuration,
                isPresented: isPresented,
                animated: animated
            )
        )
    }

    /// Opens a URL using `SFSafariViewController`.
    ///
    /// You can use this modifier in a SwiftUI view to attach Safari browsing functionality to
    /// a view and control the presentation with a binding. This method takes a binding to the
    /// URL that you want to present and the URL will be opened when the binding becomes
    /// non-nil.
    ///
    /// - Parameters:
    ///    - url: A binding to the URL to be opened.
    ///    - configuration: An optional configuration for the Safari view controller.
    ///    - animated: Controls whether or not the presentation is animated.
    ///
    func safariWebView(
        url: Binding<URL?>,
        configuration: SFSafariViewController.Configuration? = nil,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
        animated: Bool = true
    ) -> some View {
        background(
            UIViewControllerPresenting.safariViewController(
                url: url,
                configuration: configuration,
                animated: animated
            )
        )
    }
}

extension UIViewControllerPresenting where Controller == SFSafariViewController, Coordinator == SafariWebViewCoordinator {
    static func safariViewController(
        url: URL,
        configuration: SFSafariViewController.Configuration?,
        isPresented: Binding<Bool>,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
        animated: Bool = true
    ) -> Self {
        .init(
            isPresented: isPresented,
            makeUIViewController: { context, _ in
                makeSafariViewController(
                    url: url,
                    configuration: configuration,
                    delegate: context.coordinator,
                    modalPresentationStyle: modalPresentationStyle
                )
            },
            makeCoordinator: { dismissHandler in
                Coordinator(dismissHandler: dismissHandler)
            },
            animated: animated
        )
    }

    static func safariViewController(
        url: Binding<URL?>,
        configuration: SFSafariViewController.Configuration?,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
        animated: Bool = true
    ) -> Self {
        .init(
            isPresented: url.isPresent(),
            makeUIViewController: { context, _ in
                // Because we only present when the binding has a
                // value it should be safe to force unwrap here.
                makeSafariViewController(
                    url: url.wrappedValue!,
                    configuration: configuration,
                    delegate: context.coordinator,
                    modalPresentationStyle: modalPresentationStyle
                )
            },
            makeCoordinator: { dismissHandler in
                Coordinator(dismissHandler: dismissHandler)
            },
            animated: animated
        )
    }

    private static func makeSafariViewController(
        url: URL,
        configuration: SFSafariViewController.Configuration?,
        delegate: SFSafariViewControllerDelegate,
        modalPresentationStyle: UIModalPresentationStyle
    ) -> SFSafariViewController {
        let safariViewController: SFSafariViewController
        if let configuration = configuration {
            safariViewController = .init(url: url, configuration: configuration)
        } else {
            safariViewController = .init(url: url)
        }
        safariViewController.delegate = delegate
        safariViewController.modalPresentationStyle = modalPresentationStyle
        return safariViewController
    }
}

private class SafariWebViewCoordinator: NSObject, SFSafariViewControllerDelegate {
    let dismissHandler: UIViewControllerPresenting.DismissHandler

    init(dismissHandler: @escaping UIViewControllerPresenting.DismissHandler) {
        self.dismissHandler = dismissHandler
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismissHandler()
    }
}

// Taken from https://raw.githubusercontent.com/pointfreeco/swiftui-navigation/main/Sources/SwiftUINavigation/Binding.swift
// Copyright (c) 2021 Point-Free, Inc.
// License: MIT
// https://github.com/pointfreeco/swiftui-navigation/blob/main/LICENSE
extension Binding {
    public func isPresent<Wrapped>() -> Binding<Bool>
    where Value == Wrapped? {
        .init(
            get: { self.wrappedValue != nil },
            set: { isPresent, transaction in
                if !isPresent {
                    self.transaction(transaction).wrappedValue = nil
                }
            }
        )
    }
}
#endif
