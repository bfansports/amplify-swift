//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

#if os(iOS) || os(macOS) || os(visionOS)
import Foundation
import Amplify

public struct AWSAuthWebUISignInOptions {

    /// Identifier of the underlying authentication provider
    ///
    /// This can be used to identify a provider if there are multiple instance of the same authentication provider.
    /// For example if you have multiple SAML identity providers, you can identify one of them by providing this
    /// `idpIdentifier` value. If this value is set, the webUI will just show a textbox to enter the email address.
    /// On the other hand, if you do not give any value here, the webUI will show the list of identity providers and the
    /// user must select one of them to continue.
    public let idpIdentifier: String?

    /// Starts the webUI signin in a private browser session, if supported by the current browser.
    ///
    /// Note that this value internally sets `prefersEphemeralWebBrowserSession` in ASWebAuthenticationSession.
    /// As per Apple documentation, Whether the request is honored depends on the user’s default web browser.
    /// Safari always honors the request.
    public let preferPrivateSession: Bool

    /// Use SFSafariViewController instead of ASWebAuthenticationSession for the authentication flow.
    ///
    /// This is useful when you want to maintain cookie continuity with SFSafariViewController instances
    /// used elsewhere in your app, rather than sharing cookies with Safari.
    /// - Note: SFSafariViewController is only available on iOS and visionOS.
    public let preferSafariViewController: Bool

    public init(idpIdentifier: String? = nil,
                preferPrivateSession: Bool = false,
                preferSafariViewController: Bool = false) {
        self.idpIdentifier = idpIdentifier
        self.preferPrivateSession = preferPrivateSession
        self.preferSafariViewController = preferSafariViewController
    }
}

extension AuthWebUISignInRequest.Options {

    public static func preferPrivateSession() -> AuthWebUISignInRequest.Options {
        let pluginOptions = AWSAuthWebUISignInOptions(preferPrivateSession: true)
        let options = AuthWebUISignInRequest.Options(pluginOptions: pluginOptions)
        return options
    }

    /// Creates Web UI sign in options that use SFSafariViewController instead of ASWebAuthenticationSession
    ///
    /// Use this when you want to maintain cookie continuity with SFSafariViewController instances
    /// used elsewhere in your app, rather than sharing cookies with Safari.
    /// - Note: SFSafariViewController is only available on iOS and visionOS.
    /// - Returns: AuthWebUISignInRequest.Options configured to use SFSafariViewController
    public static func preferSafariViewController() -> AuthWebUISignInRequest.Options {
        let pluginOptions = AWSAuthWebUISignInOptions(preferSafariViewController: true)
        let options = AuthWebUISignInRequest.Options(pluginOptions: pluginOptions)
        return options
    }
}
#endif
