import Foundation

enum HostedUIError: Error, Equatable {
    case invalidConfiguration
    case invalidContext
    case signInURI
    case signOutURI
    case tokenURI
    case proofCalculation
    case serviceMessage(String)
    case cancelled
    case unableToStartASWebAuthenticationSession
    case unknown
}

extension HostedUIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Invalid Hosted UI configuration"
        case .invalidContext:
            return "Invalid presentation context"
        case .signInURI:
            return "Could not construct sign in URI"
        case .signOutURI:
            return "Could not construct sign out URI"
        case .tokenURI:
            return "Could not construct token URI"
        case .proofCalculation:
            return "Could not calculate proof key"
        case .serviceMessage(let message):
            return message
        case .cancelled:
            return "User cancelled the authentication"
        case .unableToStartASWebAuthenticationSession:
            return "Unable to start ASWebAuthenticationSession"
        case .unknown:
            return "Unknown error occurred during web UI authentication"
        }
    }
}