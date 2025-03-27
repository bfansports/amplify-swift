#if os(iOS)
import Amplify
import Foundation
import SafariServices


class HostedUISFSafariViewController: NSObject, HostedUISessionBehavior {
    private var continuation: CheckedContinuation<[URLQueryItem], Error>?
    private var presentationAnchor: UIWindow?
    private var safariVC: SFSafariViewController?
    private var safariVCFactory = SFSafariViewController.init(url:)

    static var currentSession: HostedUISFSafariViewController?

    func showHostedUI(
        url: URL,
        callbackScheme: String,
        inPrivate: Bool,
        presentationAnchor: AuthUIPresentationAnchor?
    ) async throws -> [URLQueryItem] {
        let window = presentationAnchor ?? getFallbackPresentationAnchor()

        guard let window else {
            throw HostedUIError.invalidContext
        }

        HostedUISFSafariViewController.currentSession = self

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.presentationAnchor = window

            self.safariVC = createSafariSession(url: url)
            self.safariVC!.delegate = self

            DispatchQueue.main.async {
                if let rootVC = window.rootViewController, let topVC = self.getTopViewController(from: rootVC), topVC.presentedViewController == nil {
                    topVC.present(self.safariVC!,   animated: true)
                } else {
                    continuation.resume(throwing: HostedUIError.invalidContext)
                }
            }
        }
    }

    private func createSafariSession(url: URL) -> SFSafariViewController {
        return safariVCFactory(url)
    }

    private func getFallbackPresentationAnchor() -> UIWindow? {
        var anchor: UIWindow?

        DispatchQueue.main.sync {
            anchor = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow && $0.rootViewController != nil })
        }

        return anchor
    }

    private func getTopViewController(from root: UIViewController?) -> UIViewController? {
        var top = root

        while let presented = top?.presentedViewController {
            top = presented
        }

        return top
    }


    func handleRedirect(_ url: URL) {
        safariVC?.dismiss(animated: true)

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        if let error = queryItems.first(where: { $0.name == "error" })?.value {
            let description = queryItems.first(where: { $0.name == "error_description" })?.value ?? ""
            continuation?.resume(throwing: HostedUIError.serviceMessage("\(error): \(description)"))
        } else {
            continuation?.resume(returning: queryItems)
        }

        continuation = nil
    }

    // private func convertHostedUIError(_ error: Error) -> HostedUIError {
    //     if let asWebAuthError = error as? ASWebAuthenticationSessionError {
    //         switch asWebAuthError.code {
    //         case .canceledLogin:
    //             return .cancelled
    //         case .presentationContextNotProvided:
    //             return .invalidContext
    //         case .presentationContextInvalid:
    //             return .invalidContext
    //         @unknown default:
    //             return .unknown
    //         }
    //     }
    //     return .unknown
    // }
}

extension HostedUISFSafariViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        continuation?.resume(throwing: HostedUIError.cancelled)
        continuation = nil
    }
}
#endif
