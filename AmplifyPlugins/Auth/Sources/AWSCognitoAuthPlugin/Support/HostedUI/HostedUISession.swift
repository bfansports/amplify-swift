import Foundation
import Amplify
#if os(iOS) || os(macOS) || os(visionOS)
import AuthenticationServices

class HostedUISession: NSObject {
    
    static func create(
        url: URL,
        callbackScheme: String,
        inPrivate: Bool,
        presentationAnchor: AuthUIPresentationAnchor?,
        preferSafariViewController: Bool
    ) -> HostedUISessionBehavior {
        #if os(iOS) || os(visionOS)
        if preferSafariViewController {
            return HostedUISafariViewController()
        }
        #endif
        return HostedUIASWebAuthenticationSession()
    }
}
#endif