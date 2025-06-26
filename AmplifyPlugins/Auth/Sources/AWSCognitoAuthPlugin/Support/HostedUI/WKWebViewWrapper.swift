#if os(iOS)
import UIKit
import WebKit

class WKWebViewWrapper: UIViewController, WKNavigationDelegate, UIAdaptivePresentationControllerDelegate {
    private let webView = WKWebView()
    private let startURL: URL
    private let callbackScheme: String
    private let onRedirect: (Result<[URLQueryItem], Error>) -> Void

    init(startURL: URL, callbackScheme: String, onRedirect: @escaping (Result<[URLQueryItem], Error>) -> Void) {
        self.startURL = startURL
        self.callbackScheme = callbackScheme
        self.onRedirect = onRedirect
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

        self.presentationController?.delegate = self
        self.webView.load(URLRequest(url: startURL))
    }

    @objc
    private func onTapClose() {
        onRedirect(.failure(HostedUIError.cancelled))
        dismiss(animated: true)
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onRedirect(.failure(HostedUIError.cancelled))
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy
    ) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        if url.scheme == callbackScheme {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queryItems = components?.queryItems ?? []

            if let error = queryItems.first(where: { $0.name == "error" })?.value {
                let desc = queryItems.first(where: { $0.name == "error_description" })?.value ?? ""
                onRedirect(.failure(HostedUIError.serviceMessage("\(error): \(desc)")))
            } else {
                onRedirect(.success(queryItems))
            }

            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
#endif
