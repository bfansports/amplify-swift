#if os(iOS)
import Amplify
import Foundation
import UIKit

class HostedUIWKWebViewAuthenticationSession: NSObject, HostedUISessionBehavior, WKWebViewAuthenticationSessionDelegate {

    private var continuation: CheckedContinuation<[URLQueryItem], Error>?
    private var webView: WKWebViewAuthenticationSession?

    static var currentSession: HostedUIWKWebViewAuthenticationSession?

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

        HostedUIWKWebViewAuthenticationSession.currentSession = self

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            DispatchQueue.main.async {
                self.webView = WKWebViewAuthenticationSession(url: url, sessionDelegate: self)
                self.webView?.presentationController?.delegate = self

                if let rootVC = window.rootViewController,
                   let topVC = self.getTopViewController(from: rootVC),
                   topVC.presentedViewController == nil
                {
                    topVC.present(self.webView!, animated: true)
                } else {
                    continuation.resume(throwing: HostedUIError.invalidContext)
                }
            }


        }
    }

    private func getFallbackPresentationAnchor() -> UIWindow? {
        var anchor: UIWindow?

        if Thread.isMainThread {
            anchor = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow && $0.rootViewController != nil })
        } else {
            DispatchQueue.main.sync {
                anchor = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first(where: { $0.isKeyWindow && $0.rootViewController != nil })
            }
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
        webView?.dismiss(animated: true)

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

    func didTapClose() {
        webView?.dismiss(animated: true)
        continuation?.resume(throwing: HostedUIError.cancelled)
        continuation = nil
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        continuation?.resume(throwing: HostedUIError.cancelled)
        continuation = nil
    }
}
#endif
