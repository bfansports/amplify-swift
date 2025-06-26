#if os(iOS)
import Amplify
import Foundation
import UIKit

class HostedUIWKWebView: NSObject, HostedUISessionBehavior {
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

        return try await withCheckedThrowingContinuation { [weak self]
            (continuation: CheckedContinuation<[URLQueryItem], Error>) in

            DispatchQueue.main.async {
                var webVC: WKWebViewWrapper?

                webVC = WKWebViewWrapper(
                    startURL: url,
                    callbackScheme: callbackScheme,
                    onRedirect: { [weak self] result in
                        DispatchQueue.main.async {
                            guard let presented = webVC else { return }

                            presented.dismiss(animated: true) {
                                switch result {
                                    case .success(let queryItems):
                                        continuation.resume(returning: queryItems)
                                    case .failure(let error):
                                        continuation.resume(throwing: error)
                                }
                            }
                        }
                    })

                if let rootVC = window.rootViewController, let topVC = self?.getTopViewController(from: rootVC), topVC.presentedViewController == nil {
                    topVC.present(webVC!, animated: true)
                } else {
                    continuation.resume(throwing: HostedUIError.invalidContext)
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
}
#endif
