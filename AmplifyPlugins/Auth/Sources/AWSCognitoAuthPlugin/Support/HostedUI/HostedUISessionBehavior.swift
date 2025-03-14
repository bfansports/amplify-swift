//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AuthenticationServices
import Amplify

/// Protocol defining the behavior for hosted UI authentication sessions
protocol HostedUISessionBehavior {
    
    /// Shows the hosted UI for authentication
    /// - Parameters:
    ///   - url: The URL to load in the authentication session
    ///   - callbackScheme: The URL scheme to use for the callback
    ///   - inPrivate: Whether to use a private session (ephemeral)
    ///   - presentationAnchor: The window or view controller to present from
    /// - Returns: The query items from the callback URL
    /// - Throws: HostedUIError if authentication fails or is cancelled
    func showHostedUI(
        url: URL,
        callbackScheme: String,
        inPrivate: Bool,
        presentationAnchor: AuthUIPresentationAnchor?
    ) async throws -> [URLQueryItem]
}
