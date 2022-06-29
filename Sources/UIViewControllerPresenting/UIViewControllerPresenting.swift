import SwiftUI
import UIKit

/// A SwiftUI view that can be used to present an arbitrary UIKit view controller.
///
/// This view takes care of all the presentation logic, allowing you to focus on the creation of the
/// UIViewController you want to present, along with any coordinator you need.
///
/// This also uses the UIKit presentation mechanism - the representable view controller is actually
/// just a basic view controller which is used to access the UIKit presentation APIs - the custom
/// view controller will be created and presented using the `.present` API.
///
/// As per the documentation for `.present`,  this means that the presentation style can depend on the
/// context - if you embed one of these views inside a leaf view, UIKit will actually go up the view
/// hierarchy to find the nearest full screen view controller and ask that to do the actual presentation.
/// If that is a `UINavigationController` (or a `NavigationView`) then it will present
/// the view controller as a push. Otherwise, it will present the view controller modally using the
/// `modalPresentationStyle` that you set on the view controller (or the default).
///
/// To use one of these views, you should simply insert them into the background of an existing
/// view and pass in a `Binding<Bool>` to control the presentation.
///
/// - Important: If the presented view controller can be automatically dismissed, e.g.
/// on completion of some activity, then you must implement any callback API (such as a
/// completion handler or a delegate call) and call the provided dismiss handler - the dismiss
/// handler is provided to both the `makeUIViewController` and `makeCoordinator`
/// closures for this purpose.
///
public struct UIViewControllerPresenting<Controller: UIViewController, Coordinator>: UIViewControllerRepresentable {
    /// A callback that should be called by the presented view controller if it dismisses itself.
    public typealias DismissHandler = () -> Void

    /// A builder closure that should return the UIViewController to be presented.
    ///
    /// If the view controller you are calling has it's own completion handler callback that is invoked
    /// when the controller is dismissed, you must set that completion handler to call the provided
    /// dismiss handler to ensure the internal presentation state is updated correctly.
    ///
    /// If the UIViewController uses a delegate-based API for handling dismissal or completion, then
    /// you should instead implement a Coordinator object and call the DismissHandler from the
    /// coordinator instead.
    ///
    /// - Parameters:
    ///    - Context: The context value, if one is present (otherwise Void).
    ///    - DismissHandler: A callback closure that can be called to indicate the controller was dismissed.
    ///
    let _makeUIViewController: (Context, @escaping DismissHandler) -> Controller

    /// A closure that should return a coordinator for this view, if one is needed.
    ///
    /// The dismiss handler callback is provided in case your coordinator needs to hold on to a reference
    /// to it in order to call it at a later time, e.g. if the view controller's delegate indicates completion or
    /// dismissal.
    ///
    /// - Parameters:
    ///    - DismissHandler: The dismiss handler - you should keep a reference to this in your
    ///     coordinator object if it needs to call it later, .e.g. in a delegate callback.
    ///
    let _makeCoordinator: (@escaping DismissHandler) -> Coordinator

    /// Controls whether the presentation should be animated or not.
    var animated: Bool = true

    /// The state used to drive the presentation and disappearance of the UIViewController.
    @Binding
    var isPresented: Bool

    /// Used to track the actual presentation state of the presented view controller.
    @State
    var isActuallyPresented: Bool = false

    private var presentationDelegate: PresentationDelegate?

    public init(
        isPresented: Binding<Bool>,
        makeUIViewController: @escaping (Context, @escaping DismissHandler) -> Controller,
        makeCoordinator: @escaping (@escaping DismissHandler) -> Coordinator,
        animated: Bool = true
    ) {
        self._isPresented = isPresented
        self._makeUIViewController = makeUIViewController
        self._makeCoordinator = makeCoordinator
        self.animated = animated
        self.presentationDelegate = .init(isPresented: isPresented, isActuallyPresented: $isActuallyPresented)
    }

    public func makeCoordinator() -> Coordinator {
        _makeCoordinator(handleDismiss)
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        // We just need a plain view controller to hook into the presentation APIs.
        let presentingViewController = UIViewController()

        if isPresented {
            // If the binding is `true` already, we should present immediately.
            presentViewController(from: presentingViewController, context: context)
        }
        return presentingViewController
    }

    public func updateUIViewController(_ presentingViewController: UIViewController, context: Context) {
        switch (isPresented, isActuallyPresented) {
        case (true, false):
            presentViewController(from: presentingViewController, context: context)
        case (false, true):
            presentingViewController.dismiss(animated: true) {
                handleDismiss()
            }
        default:
            break
        }
    }

    private func handleDismiss() {
        isActuallyPresented = false
        isPresented = false
    }

    private func presentViewController(from presentingViewController: UIViewController, context: Context) {
        let viewController = _makeUIViewController(context, handleDismiss)

        // Setting this prevents a crash on iPad
        viewController.popoverPresentationController?.sourceView = presentingViewController.view

        // Assign the delegate so we can keep track of its presentation.
        viewController.presentationController?.delegate = presentationDelegate

        presentingViewController.present(viewController, animated: animated) {
            isActuallyPresented = true
        }
    }

    private class PresentationDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
        private let isPresented: Binding<Bool>
        private let isActuallyPresented: Binding<Bool>

        init(isPresented: Binding<Bool>, isActuallyPresented: Binding<Bool>) {
            self.isPresented = isPresented
            self.isActuallyPresented = isActuallyPresented
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            // If the user swipes to dismiss the sheet, reset presentation binding.
            isPresented.wrappedValue = false
            isActuallyPresented.wrappedValue = false
        }
    }
}

// MARK: - Initialising a presenting view without a coordinator

extension UIViewControllerPresenting where Coordinator == Void {
    public init(
        isPresented: Binding<Bool>,
        makeUIViewController: @escaping (Context, @escaping DismissHandler) -> Controller,
        animated: Bool = true
    ) {
        self.init(
            isPresented: isPresented,
            makeUIViewController: makeUIViewController,
            makeCoordinator: { _ in () },
            animated: animated
        )
    }
}
