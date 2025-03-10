//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSPluginsCore
#if os(iOS) || os(visionOS)
import SafariServices
#endif

public final class AWSCognitoAuthPlugin: AWSCognitoAuthPluginBehavior {

    var customWebUIOptions: AuthWebUISignInRequest.Options?

    var authEnvironment: AuthEnvironment!

    var authStateMachine: AuthStateMachine!

    var credentialStoreStateMachine: CredentialStoreStateMachine!

     /// A queue that regulates the execution of operations.
    var queue: OperationQueue!

    /// Configuration for the auth plugin
    var authConfiguration: AuthConfiguration!

    /// Handles different auth event send through hub
    var hubEventHandler: AuthHubEventBehavior!

    var analyticsHandler: UserPoolAnalyticsBehavior!

    var taskQueue: TaskQueue<Any>!

    var httpClientEngineProxy: HttpClientEngineProxy?

    /// The user network preferences for timeout and retry
    let networkPreferences: AWSCognitoNetworkPreferences?

    /// The user secure storage preferences for access group
    let secureStoragePreferences: AWSCognitoSecureStoragePreferences?

    @_spi(InternalAmplifyConfiguration)
    internal(set) public var jsonConfiguration: JSONValue?

    /// The unique key of the plugin within the auth category.
    public var key: PluginKey {
        return "awsCognitoAuthPlugin"
    }

    /// Instantiates an instance of the AWSCognitoAuthPlugin with optional custom network
    /// preferences and optional custom secure storage preferences
    /// - Parameters:
    ///   - networkPreferences: network preferences
    ///   - secureStoragePreferences: secure storage preferences
    public init(networkPreferences: AWSCognitoNetworkPreferences? = nil,
                secureStoragePreferences: AWSCognitoSecureStoragePreferences = AWSCognitoSecureStoragePreferences()) {
        self.networkPreferences = networkPreferences
        self.secureStoragePreferences = secureStoragePreferences
    }
}

class HostedUISafariViewController: NSObject, HostedUISessionBehavior {

    weak var safariViewController: SFSafariViewController?
    weak var presentationController: UIViewController?

    func showHostedUI(
        url: URL,
        callbackScheme: String,
        inPrivate: Bool,
        presentationAnchor: AuthUIPresentationAnchor?) async throws -> [URLQueryItem] {

    #if os(iOS) || os(visionOS)
        guard let presentationAnchor = presentationAnchor as? UIViewController else {
            throw HostedUIError.invalidContext
        }

        self.presentationController = presentationAnchor

        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return }

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleURLOpened(_:)),
                name: .amplifyHostedUICompleted,
                object: nil)

            let safariConfig = SFSafariViewController.Configuration()
            safariConfig.entersReaderIfAvailable = false

            let safariVC = SFSafariViewController(url: url, configuration: safariConfig)
            safariVC.delegate = self

            // Store continuation for when we get the callback
            self.continuation = continuation
            self.callbackURLScheme = callbackScheme
            self.safariViewController = safariVC

            DispatchQueue.main.async {
                presentationAnchor.present(safariVC, animated: true, completion: nil)
            }
        }
    #else
        throw HostedUIError.serviceMessage("HostedUISafariViewController is only available in iOS and visionOS")
    #endif
    }

#if os(iOS) || os(visionOS)
    // Properties to manage the async flow
    private var continuation: CheckedContinuation<[URLQueryItem], Error>?
    private var callbackURLScheme: String?

    @objc private func handleURLOpened(_ notification: Notification) {
        guard let url = notification.object as? URL,
              let urlScheme = url.scheme,
              let callbackScheme = callbackURLScheme,
              urlScheme.caseInsensitiveCompare(callbackScheme) == .orderedSame else {
            return
        }

        // Process the URL
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = urlComponents?.queryItems ?? []

        // Check for errors in query parameters
        if let error = queryItems.first(where: { $0.name == "error" })?.value {
            let errorDescription = queryItems.first(
                where: { $0.name == "error_description" }
            )?.value?.trim() ?? ""
            let message = "\(error) \(errorDescription)"
            continuation?.resume(throwing: HostedUIError.serviceMessage(message))
        } else {
            continuation?.resume(returning: queryItems)
        }

        // Clean up
        self.safariViewController?.dismiss(animated: true)
        self.continuation = nil
        self.callbackURLScheme = nil

        NotificationCenter.default.removeObserver(
            self,
            name: .amplifyHostedUICompleted,
            object: nil)
    }
#endif
}

#if os(iOS) || os(visionOS)
extension HostedUISafariViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // User cancelled the authentication flow
        continuation?.resume(throwing: HostedUIError.cancelled)
        continuation = nil
        callbackURLScheme = nil

        NotificationCenter.default.removeObserver(
            self,
            name: .amplifyHostedUICompleted,
            object: nil)
    }
}

extension Notification.Name {
    // Define a notification name that will be posted when the app receives the callback URL
    static let amplifyHostedUICompleted = Notification.Name("AmplifyHostedUICompleted")
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
#endif