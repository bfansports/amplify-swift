//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSCognitoIdentityProvider
@_spi(UnknownAWSHTTPServiceError) import AWSClientRuntime

extension ForbiddenException: AuthErrorConvertible {
    var fallbackDescription: String { "Access to the requested resource is forbidden" }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.forbiddenError
        )
    }
}

extension InternalErrorException: AuthErrorConvertible {
    var fallbackDescription: String { "Internal exception occurred" }

    var authError: AuthError {
        .unknown(properties.message ?? fallbackDescription)
    }
}

extension InvalidParameterException: AuthErrorConvertible {
    var fallbackDescription: String { "Invalid parameter error" }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.invalidParameterError,
            AWSCognitoAuthError.invalidParameter
        )
    }
}

extension InvalidPasswordException: AuthErrorConvertible {
    var fallbackDescription: String { "Encountered invalid password." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.invalidPasswordError,
            AWSCognitoAuthError.invalidPassword
        )
    }
}

extension LimitExceededException: AuthErrorConvertible {
    var fallbackDescription: String { "Limit exceeded error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.limitExceededError,
            AWSCognitoAuthError.limitExceeded
        )
    }
}

extension NotAuthorizedException: AuthErrorConvertible {
    var fallbackDescription: String { "Not authorized error." }

    var authError: AuthError {
        .notAuthorized(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.notAuthorizedError
        )
    }
}

extension PasswordResetRequiredException: AuthErrorConvertible {
    var fallbackDescription: String { "Password reset required error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.passwordResetRequired,
            AWSCognitoAuthError.passwordResetRequired
        )
    }
}

extension ResourceNotFoundException: AuthErrorConvertible {
    var fallbackDescription: String { "Resource not found error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.resourceNotFoundError,
            AWSCognitoAuthError.resourceNotFound
        )
    }
}

extension TooManyRequestsException: AuthErrorConvertible {
    var fallbackDescription: String { "Too many requests error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.tooManyRequestError,
            AWSCognitoAuthError.requestLimitExceeded
        )
    }
}

extension UserNotConfirmedException: AuthErrorConvertible {
    var fallbackDescription: String { "User not confirmed error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.userNotConfirmedError,
            AWSCognitoAuthError.userNotConfirmed
        )
    }
}

extension UserNotFoundException: AuthErrorConvertible {
    var fallbackDescription: String { "User not found error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.userNotFoundError,
            AWSCognitoAuthError.userNotFound
        )
    }
}

extension CodeMismatchException: AuthErrorConvertible {
    var fallbackDescription: String { "Provided code does not match what the server was expecting." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.codeMismatchError,
            AWSCognitoAuthError.codeMismatch
        )
    }
}

extension InvalidLambdaResponseException: AuthErrorConvertible {
    var fallbackDescription: String { "Invalid lambda response error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.lambdaError,
            AWSCognitoAuthError.lambda
        )
    }
}

extension ExpiredCodeException: AuthErrorConvertible {
    var fallbackDescription: String { "Provided code has expired." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.codeExpiredError,
            AWSCognitoAuthError.codeExpired
        )
    }
}

extension TooManyFailedAttemptsException: AuthErrorConvertible {
    var fallbackDescription: String { "Too many failed attempts error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.tooManyFailedError,
            AWSCognitoAuthError.failedAttemptsLimitExceeded
        )
    }
}

extension UnexpectedLambdaException: AuthErrorConvertible {
    var fallbackDescription: String { "Unexpected lambda error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.lambdaError,
            AWSCognitoAuthError.lambda
        )
    }
}

extension UserLambdaValidationException: AuthErrorConvertible {
    var fallbackDescription: String { "User lambda validation error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.lambdaError,
            AWSCognitoAuthError.lambda
        )
    }
}

extension AliasExistsException: AuthErrorConvertible {
    var fallbackDescription: String { "Alias exists error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.aliasExistsError,
            AWSCognitoAuthError.aliasExists
        )
    }
}

extension InvalidUserPoolConfigurationException: AuthErrorConvertible {
    var fallbackDescription: String { "Invalid UserPool Configuration error." }

    var authError: AuthError {
        .configuration(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.configurationError
        )
    }
}

extension CodeDeliveryFailureException: AuthErrorConvertible {
    var fallbackDescription: String { "Code Delivery Failure error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.codeDeliveryError,
            AWSCognitoAuthError.codeDelivery
        )
    }
}

extension InvalidEmailRoleAccessPolicyException: AuthErrorConvertible {
    var fallbackDescription: String { "Invalid email role access policy error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.invalidEmailRoleError,
            AWSCognitoAuthError.emailRole
        )
    }
}

extension InvalidSmsRoleAccessPolicyException: AuthErrorConvertible {
    var fallbackDescription: String { "Invalid SMS Role Access Policy error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.invalidSMSRoleError,
            AWSCognitoAuthError.smsRole
        )
    }
}

extension InvalidSmsRoleTrustRelationshipException: AuthErrorConvertible {
    var fallbackDescription: String { "Invalid SMS Role Trust Relationship error." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.invalidSMSRoleError,
            AWSCognitoAuthError.smsRole
        )
    }
}

extension MFAMethodNotFoundException: AuthErrorConvertible {
    var fallbackDescription: String { "Amazon Cognito cannot find a multi-factor authentication (MFA) method." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.mfaMethodNotFoundError,
            AWSCognitoAuthError.mfaMethodNotFound
        )
    }
}

extension SoftwareTokenMFANotFoundException: AuthErrorConvertible {
    var fallbackDescription: String { "Software token TOTP multi-factor authentication (MFA) is not enabled for the user pool." }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.softwareTokenNotFoundError,
            AWSCognitoAuthError.softwareTokenMFANotEnabled
        )
    }
}

extension UsernameExistsException: AuthErrorConvertible {
    var fallbackDescription: String { "Username exists error" }

    var authError: AuthError {
        .service(
            properties.message ?? fallbackDescription,
            AuthPluginErrorConstants.userNameExistsError,
            AWSCognitoAuthError.usernameExists
        )
    }
}

extension AWSCognitoIdentityProvider.ConcurrentModificationException: AuthErrorConvertible {
    var fallbackDescription: String { "Concurrent modification error" }

    var authError: AuthError {
        .service(
            message ?? fallbackDescription,
            AuthPluginErrorConstants.concurrentModificationException
        )
    }
}

extension AWSCognitoIdentityProvider.EnableSoftwareTokenMFAException: AuthErrorConvertible {
    var fallbackDescription: String { "Unable to enable software token MFA" }

    var authError: AuthError {
        .service(
            message ?? fallbackDescription,
            AuthPluginErrorConstants.softwareTokenNotFoundError,
            AWSCognitoAuthError.softwareTokenMFANotEnabled
        )
    }
}

extension AWSCognitoIdentityProvider.WebAuthnChallengeNotFoundException: AuthErrorConvertible {
    var fallbackDescription: String { "The credentials provided don't match an existing request" }

    var authError: AuthError {
        .service(
            message ?? fallbackDescription,
            AuthPluginErrorConstants.webAuthnChallengeNotFound,
            AWSCognitoAuthError.webAuthnChallengeNotFound
        )
    }
}

extension AWSCognitoIdentityProvider.WebAuthnClientMismatchException: AuthErrorConvertible {
    var fallbackDescription: String { "The App client doesn't support WebAuthn authentication" }

    var authError: AuthError {
        .service(
            message ?? fallbackDescription,
            AuthPluginErrorConstants.webAuthnClientMismatch,
            AWSCognitoAuthError.webAuthnClientMismatch
        )
    }
}

extension AWSCognitoIdentityProvider.WebAuthnCredentialNotSupportedException: AuthErrorConvertible {
    var fallbackDescription: String { "The device is unsupported" }

    var authError: AuthError {
        .service(
            message ?? fallbackDescription,
            AuthPluginErrorConstants.webAuthnCredentialNotSupported,
            AWSCognitoAuthError.webAuthnNotSupported
        )
    }
}

extension AWSCognitoIdentityProvider.WebAuthnNotEnabledException: AuthErrorConvertible {
    var fallbackDescription: String { "WebAuthn authentication is not enabled" }

    var authError: AuthError {
        .service(
            message ?? fallbackDescription,
            AuthPluginErrorConstants.webAuthnNotEnabled,
            AWSCognitoAuthError.webAuthnNotEnabled
        )
    }
}

extension AWSCognitoIdentityProvider.WebAuthnOriginNotAllowedException: AuthErrorConvertible {
    var fallbackDescription: String { "The device origin is not registered as an allowed origin" }

    var authError: AuthError {
        .service(
            message ?? fallbackDescription,
            AuthPluginErrorConstants.webAuthnOriginNotAllowed,
            AWSCognitoAuthError.webAuthnOriginNotAllowed
        )
    }
}

extension AWSCognitoIdentityProvider.WebAuthnRelyingPartyMismatchException: AuthErrorConvertible {
    var fallbackDescription: String { "The credential does not match the relying party ID" }

    var authError: AuthError {
        .service(
            message ?? fallbackDescription,
            AuthPluginErrorConstants.webAuthnRelyingPartyMismatch,
            AWSCognitoAuthError.webAuthnRelyingPartyMismatch
        )
    }
}

extension AWSCognitoIdentityProvider.WebAuthnConfigurationMissingException: AuthErrorConvertible {
    var fallbackDescription: String { "The WebAuthm configuration is missing" }

    var authError: AuthError {
        .service(
            message ?? fallbackDescription,
            AuthPluginErrorConstants.webAuthnConfigurationMissing,
            AWSCognitoAuthError.webAuthnConfigurationMissing
        )
    }
}

extension AWSClientRuntime.UnknownAWSHTTPServiceError: AuthErrorConvertible {
    var fallbackDescription: String { "" }

    var authError: AuthError {
        .unknown(
            """
            Unknown service error occured with:
            - status: \(httpResponse.statusCode)
            - message: \(message ?? fallbackDescription)
            """,
            self
        )
    }
}
