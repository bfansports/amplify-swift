#if os(iOS)
import UIKit
import WebKit

protocol WKWebViewAuthenticationSessionDelegate: UIAdaptivePresentationControllerDelegate {
    func didTapClose()
}

class WKWebViewAuthenticationSession: UIViewController, WKNavigationDelegate {
    private let webView = WKWebView()
    private let url: URL
    private let sessionDelegate: WKWebViewAuthenticationSessionDelegate

    init(url: URL, sessionDelegate: WKWebViewAuthenticationSessionDelegate) {
        self.url = url
        self.sessionDelegate = sessionDelegate
        super.init(nibName: nil, bundle: nil)

        self.modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 15.0, *) {
            if let sheetController = self.presentationController as? UISheetPresentationController {
                sheetController.prefersGrabberVisible = true
            }
        }

        let navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false

        let navigationItem = UINavigationItem()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(onTapClose)
        )
        navigationBar.setItems([navigationItem], animated: false)

        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.allowsLinkPreview = true
        self.webView.navigationDelegate = self
        self.webView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(navigationBar)
        self.view.addSubview(self.webView)
        self.view.backgroundColor = .systemBackground

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

            self.webView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

        self.presentationController?.delegate = sessionDelegate
        self.webView.load(URLRequest(url: url))
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {

        if let url = navigationAction.request.url,
            !url.absoluteString.hasPrefix("http://"),
            !url.absoluteString.hasPrefix("https://"),
            UIApplication.shared.canOpenURL(url) {

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    @objc
    private func onTapClose() {
        self.sessionDelegate.didTapClose()
    }
}
#endif
