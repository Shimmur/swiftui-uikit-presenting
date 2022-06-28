import SwiftUI
import UIKit

// MARK: - Presenting SwiftUI views using UIKit presentation.

public extension View {
    /// Presents SwiftUI content using UIKit sheet presentation mechanics.
    ///
    /// This view modifier allows you to use a binding to trigger a sheet presentation
    /// of the given SwiftUI content, which is automatically wrapped in a `UIHostingController`.
    ///
    /// Because this is built on top of UIKit presentation, it gives access to sheet presentation APIs
    /// that are only available in UIKit, such as detents for custom height sheets. To customise the
    /// sheet presentation, supply a sheet configuration that configures the sheet presentation
    /// controller to your requirements.
    ///
    /// ```
    /// if #available(iOS 15, *) {
    ///     Button { showsHalfSheet = true } label: {
    ///         Text("Show Half Sheet")
    ///     }
    ///     .buttonStyle(.plain)
    ///     .presenting(
    ///         isPresented: $showsHalfSheet,
    ///         sheetConfiguration: .halfSheet
    ///     ) {
    ///         VStack(spacing: 10) {
    ///             Text("This is a sheet shown by UIKit presentation.")
    ///             Button { showsHalfSheet = false } label: {
    ///                 Text("Dismiss")
    ///             }
    ///             .buttonStyle(.borderless)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///    - isPresented: A binding that determines when the sheet should be presented.
    ///    - animated: Whether or not the sheet should be presented with animation.
    ///    - modalPresentationStyle: The modal presentation style for the sheet.
    ///    - sheetConfiguration: Used to configure the hosting controller's sheet presentation controller.
    ///    - content: A SwiftUI view builder that returns the content to be presented in the sheet.
    ///
    @available(iOS 15.0, *)
    func presenting<Content: View>(
        isPresented: Binding<Bool>,
        animated: Bool = true,
        modalPresentationStyle: UIModalPresentationStyle = .automatic,
        sheetConfiguration: SheetConfiguration = .default,
        @ViewBuilder content: () -> Content
    ) -> some View {
        background(
            UIViewControllerPresenting.content(
                content(),
                isPresented: isPresented,
                sheetConfiguration: sheetConfiguration,
                animated: animated
            )
        )
    }

    /// Presents SwiftUI content using UIKit sheet presentation mechanics.
    ///
    /// This view modifier allows you to use a binding to trigger a sheet presentation of a
    /// of the given SwiftUI content, which is automatically wrapped in a `UIHostingController`.
    ///
    /// This overload does not support advanced sheet configuration and is made available for
    /// backwards compatibility with iOS 14.
    ///
    /// - Parameters:
    ///    - isPresented: A binding that determines when the sheet should be presented.
    ///    - animated: Whether or not the sheet should be presented with animation.
    ///    - modalPresentationStyle: The modal presentation style for the sheet.
    ///    - content: A SwiftUI view builder that returns the content to be presented in the sheet.
    ///
    func presenting<Content: View>(
        isPresented: Binding<Bool>,
        animated: Bool = true,
        modalPresentationStyle: UIModalPresentationStyle = .automatic,
        @ViewBuilder content: () -> Content
    ) -> some View {
        background(
            UIViewControllerPresenting.content(
                content(),
                isPresented: isPresented,
                animated: animated
            )
        )
    }
}

fileprivate extension UIViewControllerPresenting where Coordinator == Void {
    @available(iOS 15.0, *)
    static func content<Content: View>(
        _ content: Content,
        isPresented: Binding<Bool>,
        modalPresentationStyle: UIModalPresentationStyle = .automatic,
        sheetConfiguration: SheetConfiguration = .default,
        animated: Bool = true
    ) -> Self where Controller == UIHostingController<Content> {
        .init(isPresented: isPresented) { _, _ in
            let hostingController = UIHostingController(rootView: content)
            hostingController.modalPresentationStyle = modalPresentationStyle
            if let sheet = hostingController.sheetPresentationController {
                sheetConfiguration.configure(sheet)
            }
            return hostingController
        }
    }

    static func content<Content: View>(
        _ content: Content,
        isPresented: Binding<Bool>,
        modalPresentationStyle: UIModalPresentationStyle = .automatic,
        animated: Bool = true
    ) -> Self where Controller == UIHostingController<Content> {
        .init(isPresented: isPresented) { _, _ in
            let hostingController = UIHostingController(rootView: content)
            hostingController.modalPresentationStyle = modalPresentationStyle
            return hostingController
        }
    }
}

/// A type that configures a sheet presentation controller.
@available(iOS 15.0, *)
public struct SheetConfiguration {
    /// A closure that will be called to configure the sheet presentation controller before presentation.
    var configure: (UISheetPresentationController) -> Void

    public init(configure: @escaping (UISheetPresentationController) -> Void) {
        self.configure = configure
    }
}

@available(iOS 15.0, *)
public extension SheetConfiguration {
    /// The default sheet configuration, which does not make any changes to the sheet presentation controller.
    static let `default` = SheetConfiguration(configure: { _ in })

    /// A sheet configuration that presents a sheet at a fixed half screen height with no grabber visible.
    static let halfSheet = SheetConfiguration {
        $0.detents = [.medium()]
        $0.prefersGrabberVisible = false
    }

    /// A sheet configuration that presents a sheet at half screen height, but expandable to full screen.
    ///
    /// - Parameters:
    ///    - prefersGrabberVisible: Determines if the grabber should be visible.
    static func expandableHalfSheet(prefersGrabberVisible: Bool = true) -> Self {
        SheetConfiguration {
            $0.detents = [.medium(), .large()]
            $0.prefersGrabberVisible = prefersGrabberVisible
        }
    }
}

