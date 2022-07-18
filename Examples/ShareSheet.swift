import LinkPresentation
import SwiftUI
import UniformTypeIdentifiers
import UIKit

public extension View {
    /// An example of how to present a share sheet (UIActivityViewController) from SwiftUI.
    ///
    /// It is possible to simply wrap UIActivityViewController in a `UIViewControllerRepresentable` view and present that
    /// using the native SwiftUI share APIs however this causes the share sheet to appear as a full screen modal, rather than the three
    /// quarter height presentation that it usually appears with when presented using UIKit modal presentation.
    ///
    /// This is not an exhaustive example and you would normally build something like this that is very specific to your app and what
    /// kind of items you want to share.
    ///
    /// - Parameters:
    ///    - activityItems: The items you want to share.
    ///    - isPresented: A binding that indicates if this sheet should be visible - will be set back to `false` when the sheet is dismissed.
    ///    - onCompletion: Called when the user shares the items or dismisses the share sheet without sharing.
    ///
    func shareSheet(
        activityItems: [Any],
        isPresented: Binding<Bool>,
        onCompletion: UIActivityViewController.CompletionWithItemsHandler? = nil
    ) -> some View {
        background(
            UIViewControllerPresenting.shareSheet(
                activityItems: activityItems,
                isPresented: isPresented,
                completionHandler: onCompletion
            )
        )
    }
}

private extension UIViewControllerPresenting where Controller == UIActivityViewController {
    static func shareSheet(
        activityItems: [Any],
        isPresented: Binding<Bool>,
        completionHandler: UIActivityViewController.CompletionWithItemsHandler? = nil
    ) -> Self {
        .init(
            isPresented: isPresented,
            makeUIViewController: { context, dismissHandler in
                let activityController = UIActivityViewController(
                    activityItems: activityItems,
                    applicationActivities: nil
                )
                activityController.completionWithItemsHandler = {
                    completionHandler?($0, $1, $2, $3)
                    dismissHandler()
                }
                return activityController
            }
        )
    }
}

struct PhoneNumberShareSheet_Previews: PreviewProvider {
    struct PreviewView: View {
        @State var isShowingShareSheet = false

        var body: some View {
            Button("Open Share Sheet") {
                isShowingShareSheet = true
            }
            .phoneNumberShareSheet(
                activityItems: ["Hello World"],
                isPresented: $isShowingShareSheet
            )
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
