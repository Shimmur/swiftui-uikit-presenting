public extension View {
    /// Presents a native mail compose interface using MFMailComposeViewController.
    ///
    /// If mail composing is not available on this device, it will try to automatically
    /// fall back to opening a mailto: URL using the first recipient and subject.
    ///
    /// This example demonstrates how you can use a `ViewModifier` to enhance the
    /// functionality of the wrapped view controller with extra state or the SwiftUI environment.
    ///
    /// It also demonstrates how to work with delegate-based callbacks when a controller is dismissed.
    ///
    /// - Parameters:
    ///    - recipients: A list of email addresses that the email should be addressed to.
    ///    - subject: A default subject for the email.
    ///    - body: A default body for the email.
    ///    - isHTML: Indicates if the email body contains HTML or is plain text.
    ///    - isPresented: A binding to drive the appearance of the sheet.
    ///
    func mailComposeSheet(
        recipients: [String] = [],
        subject: String = "",
        body: String = "",
        isHTML: Bool = false,
        isPresented: Binding<Bool>
    ) -> some View {
        modifier(
            MailComposeViewModifier(
                template: .init(
                    recipients: recipients,
                    subject: subject,
                    body: body,
                    isHTML: isHTML
                ),
                isPresented: isPresented
            )
        )
    }

    /// Presents a native mail compose interface using MFMailComposeViewController.
        ///
        /// If mail composing is not available on this device, it will try to automatically
        /// fall back to opening a mailto URL using the first recipient and subject.
        ///
        /// - Parameters:
        ///    - template: The template to use for the mail compose view.
        ///    - isPresented: A binding to drive the appearance of the sheet.
        ///
    func mailComposeSheet(
        template: MailComposeTemplate,
        isPresented: Binding<Bool>
    ) -> some View {
        modifier(
            MailComposeViewModifier(
                template: template,
                isPresented: isPresented
            )
        )
    }
}

private struct MailComposeViewModifier: ViewModifier {
    let template: MailComposeTemplate
    let isPresented: Binding<Bool>

    @Environment(\.openURL)
    private var openURL: OpenURLAction

    func body(content: Content) -> some View {
        content.background(
            UIViewControllerPresenting(
                isPresented: .init(
                    get: {
                        // We only want to present a mail compose view controller
                        // if mail is available - if not we should override the
                        // binding to always return false.
                        guard MFMailComposeViewController.canSendMail() else {
                            return false
                        }
                        return isPresented.wrappedValue
                    },
                    set: { isPresented.wrappedValue = $0 }
                ),
                makeUIViewController: { context, _ in
                    let mailComposer = MFMailComposeViewController()
                    mailComposer.setSubject(template.subject)
                    mailComposer.setToRecipients(template.recipients)
                    mailComposer.setMessageBody(template.body, isHTML: template.isHTML)
                    mailComposer.mailComposeDelegate = context.coordinator
                    return mailComposer
                },
                makeCoordinator: { _ in
                    MailComposeViewCoordinator { isPresented.wrappedValue = false }
                }
            )
            .onChange(of: isPresented.wrappedValue) { shouldPresent in
                if shouldPresent && !MFMailComposeViewController.canSendMail() {
                    // We need to set this immediately back to false again because
                    // we aren't going to present anything and need to reset the state.
                    isPresented.wrappedValue = false
                    // If we can construct a mailto: link from the template we can
                    // fall back to opening that instead.
                    if let mailto = template.mailToLink {
                        openURL(mailto)
                    }
                }
            }
        )
    }
}

/// Defines a preset email template for use with `.mailComposeSheet`.
public struct MailComposeTemplate {
    let recipients: [String]
    let subject: String
    let body: String
    let isHTML: Bool

    public init(
        recipients: [String] = [],
        subject: String = "",
        body: String = "",
        isHTML: Bool = false
    ) {
        self.recipients = recipients
        self.subject = subject
        self.body = body
        self.isHTML = isHTML
    }

    fileprivate var mailToLink: URL? {
        guard
            let recipient = recipients.first,
            let url = URL.mailTo(recipient: recipient, subject: subject)
        else { return nil }
        return url
    }
}

private class MailComposeViewCoordinator: NSObject, MFMailComposeViewControllerDelegate {
    var dismiss: () -> Void

    init(dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }

    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        // TODO: Maybe add some error handling?
        dismiss()
    }
}
