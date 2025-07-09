#if os(iOS)
import Amplify
import Foundation
import SafariServices

class HostedUISFSafariViewController: NSObject, HostedUISessionBehavior {
    private var continuation: CheckedContinuation<[URLQueryItem], Error>?
    private var safariVC: SFSafariViewController?

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

        // Ensure only one session is active at a time
        if let currentSession = HostedUISFSafariViewController.currentSession,
           let safariVC = currentSession.safariVC {
            safariVC.dismiss(animated: false)
            currentSession.cancel()
        }

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                self.continuation = continuation
                self.safariVC = SFSafariViewController(url: url)
                self.safariVC!.delegate = self
                HostedUISFSafariViewController.currentSession = self

                if let rootVC = window.rootViewController, let topVC = self.getTopViewController(from: rootVC), topVC.presentedViewController == nil {
                    topVC.present(self.safariVC!, animated: true)
                } else {
                    continuation.resume(throwing: HostedUIError.invalidContext)
                    self.cleanUp()
                }
            }
        }
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

        cleanUp()
    }

    private func cleanUp() {
        continuation = nil
        safariVC = nil
        HostedUISFSafariViewController.currentSession = nil
    }

    func cancel() {
        continuation?.resume(throwing: HostedUIError.cancelled)
        cleanUp()
    }
}

extension HostedUISFSafariViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        cancel()
    }
}
#endif
