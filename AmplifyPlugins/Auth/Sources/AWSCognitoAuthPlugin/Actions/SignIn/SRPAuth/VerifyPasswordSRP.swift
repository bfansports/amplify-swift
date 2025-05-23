//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation
import AWSCognitoIdentityProvider

struct VerifyPasswordSRP: Action {
    let identifier = "VerifyPasswordSRP"

    let stateData: SRPStateData
    let authResponse: SignInResponseBehavior
    let clientMetadata: ClientMetadata

    init(stateData: SRPStateData,
         authResponse: SignInResponseBehavior,
         clientMetadata: ClientMetadata) {
        self.stateData = stateData
        self.authResponse = authResponse
        self.clientMetadata = clientMetadata
    }

    func execute(withDispatcher dispatcher: EventDispatcher,
                 environment: Environment) async {

        logVerbose("\(#fileID) Starting execution", environment: environment)
        let inputUsername = stateData.username
        var username = inputUsername
        var deviceMetadata = DeviceMetadata.noData
        do {
            let srpEnv = try environment.srpEnvironment()
            let userPoolEnv = try environment.userPoolEnvironment()
            let srpClient = try SRPSignInHelper.srpClient(srpEnv)
            let parameters = try challengeParameters()

            username = parameters["USERNAME"] ?? inputUsername
            let userIdForSRP = parameters["USER_ID_FOR_SRP"] ?? inputUsername
            let saltHex = try saltHex(parameters)
            let secretBlockString = try secretBlockString(parameters)
            let secretBlock = try secretBlock(secretBlockString)
            let serverPublicB = try serverPublic(parameters)

            let asfDeviceId = try await CognitoUserPoolASF.asfDeviceID(
                for: username,
                credentialStoreClient: environment.authEnvironment().credentialsClient)

            deviceMetadata = await DeviceMetadataHelper.getDeviceMetadata(
                for: username,
                with: environment)
            let signature = try signature(userIdForSRP: userIdForSRP,
                                          saltHex: saltHex,
                                          secretBlock: secretBlock,
                                          serverPublicBHexString: serverPublicB,
                                          srpClient: srpClient,
                                          poolId: userPoolEnv.userPoolConfiguration.poolId)
            let request = await RespondToAuthChallengeInput.passwordVerifier(
                username: username,
                stateData: stateData,
                session: authResponse.session,
                secretBlock: secretBlockString,
                signature: signature,
                clientMetadata: clientMetadata,
                deviceMetadata: deviceMetadata,
                asfDeviceId: asfDeviceId,
                environment: userPoolEnv)
            let responseEvent = try await UserPoolSignInHelper.sendRespondToAuth(
                request: request,
                for: username,
                signInMethod: .apiBased(.userSRP),
                environment: userPoolEnv)
            logVerbose("\(#fileID) Sending event \(responseEvent)",
                       environment: environment)
            await dispatcher.send(responseEvent)
        } catch let error as SignInError {
            logVerbose("\(#fileID) SRPSignInError \(error)", environment: environment)
            let event = SignInEvent(
                eventType: .throwPasswordVerifierError(error)
            )
            logVerbose("\(#fileID) Sending event \(event)",
                       environment: environment)
            await dispatcher.send(event)
        } catch let error where deviceNotFound(error: error, deviceMetadata: deviceMetadata) {
            logVerbose("\(#fileID) Received device not found \(error)", environment: environment)
            // Remove the saved device details and retry password verify
            await DeviceMetadataHelper.removeDeviceMetaData(for: username, with: environment)
            let event = SignInEvent(eventType: .retryRespondPasswordVerifier(stateData, authResponse, clientMetadata))
            logVerbose("\(#fileID) Sending event \(event)",
                       environment: environment)
            await dispatcher.send(event)
        } catch {
            logVerbose("\(#fileID) SRPSignInError Generic \(error)", environment: environment)
            let authError = SignInError.service(error: error)
            let event = SignInEvent(
                eventType: .throwAuthError(authError)
            )
            logVerbose("\(#fileID) Sending event \(event)",
                       environment: environment)
            await dispatcher.send(event)
        }
    }

    func deviceNotFound(error: Error, deviceMetadata: DeviceMetadata) -> Bool {

        // If deviceMetadata was not send, the error returned is not from device not found.
        if case .noData = deviceMetadata {
            return false
        }

        return error is AWSCognitoIdentityProvider.ResourceNotFoundException
    }
}

extension VerifyPasswordSRP: DefaultLogger {
    public static var log: Logger {
        Amplify.Logging.logger(forCategory: CategoryType.auth.displayName, forNamespace: String(describing: self))
    }

    public var log: Logger {
        Self.log
    }
}

extension VerifyPasswordSRP: CustomDebugDictionaryConvertible {
    var debugDictionary: [String: Any] {
        [
            "identifier": identifier,
            "stateData": stateData.debugDictionary,
            "authResponse": authResponse
        ]
    }
}

extension VerifyPasswordSRP: CustomDebugStringConvertible {
    var debugDescription: String {
        debugDictionary.debugDescription
    }
}
