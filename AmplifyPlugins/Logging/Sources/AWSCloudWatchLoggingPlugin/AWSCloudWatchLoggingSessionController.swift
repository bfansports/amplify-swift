//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSPluginsCore
@_spi(PluginHTTPClientEngine) import InternalAmplifyCredentials
import Amplify
import Combine
import Foundation
import AWSCloudWatchLogs
import Network
import SmithyIdentity

/// Responsible for setting up and tearing-down log sessions for a given category/tag according to changes in
/// user authentication sessions.
///
/// - Tag: CloudWatchLogSessionController
final class AWSCloudWatchLoggingSessionController {

    var client: CloudWatchLogsClientProtocol?
    let namespace: String?
    private let logGroupName: String
    private let region: String
    private let localStoreMaxSizeInMB: Int
    private let credentialIdentityResolver: any AWSCredentialIdentityResolver
    private let authentication: AuthCategoryUserBehavior
    private let category: String
    private var session: AWSCloudWatchLoggingSession?
    private var consumer: LogBatchConsumer?
    private let logFilter: AWSCloudWatchLoggingFilterBehavior
    private let networkMonitor: LoggingNetworkMonitor

    private var batchSubscription: AnyCancellable? {
        willSet {
            batchSubscription?.cancel()
        }
    }

    private var authSubscription: AnyCancellable? {
        willSet {
            authSubscription?.cancel()
        }
    }
    private var userIdentifier: String? {
        didSet {
            if oldValue != userIdentifier {
                userIdentifierDidChange()
            }
        }
    }

    var logLevel: LogLevel {
        didSet {
            self.session?.logger.logLevel = logLevel
        }
    }

    /// - Tag: CloudWatchLogSessionController.init
    init(credentialIdentityResolver: some AWSCredentialIdentityResolver,
         authentication: AuthCategoryUserBehavior,
         logFilter: AWSCloudWatchLoggingFilterBehavior,
         category: String,
         namespace: String?,
         logLevel: LogLevel,
         logGroupName: String,
         region: String,
         localStoreMaxSizeInMB: Int,
         userIdentifier: String?,
         networkMonitor: LoggingNetworkMonitor
    ) {
        self.credentialIdentityResolver = credentialIdentityResolver
        self.authentication = authentication
        self.logFilter = logFilter
        self.category = category
        self.namespace = namespace
        self.logLevel = logLevel
        self.logGroupName = logGroupName
        self.region = region
        self.localStoreMaxSizeInMB = localStoreMaxSizeInMB
        self.userIdentifier = userIdentifier
        self.networkMonitor = networkMonitor
    }

    func enable() {
        updateSession()
        updateConsumer()
        connectProducerAndConsumer()
    }

    func disable() {
        self.batchSubscription = nil
        self.authSubscription = nil
        self.session = nil
        self.consumer = nil
    }

    private func updateConsumer() {
        self.consumer = try? createConsumer()
    }

    private func createConsumer() throws -> LogBatchConsumer? {
        if self.client == nil {
            let configuration = try CloudWatchLogsClient.CloudWatchLogsClientConfiguration(
                awsCredentialIdentityResolver: credentialIdentityResolver,
                region: region,
                signingRegion: region
            )

            configuration.httpClientEngine = .userAgentEngine(for: configuration)

            self.client = CloudWatchLogsClient(config: configuration)
        }

        guard let cloudWatchClient = client else { return nil }
        return CloudWatchLoggingConsumer(
            client: cloudWatchClient,
            logGroupName: self.logGroupName,
            userIdentifier: self.userIdentifier)
    }

    private func connectProducerAndConsumer() {
        guard let consumer = consumer else {
            self.batchSubscription = nil
            return
        }
        guard let producer = session else {
            self.batchSubscription = nil
            return
        }
        self.batchSubscription = producer.logBatchPublisher.sink { [weak self] batch in
            guard self?.networkMonitor.isOnline == true else { return }
            
            // Capture strong references to consumer and batch before the async task
            let strongConsumer = consumer
            let strongBatch = batch
            
            Task {
                do {
                    try await strongConsumer.consume(batch: strongBatch)
                } catch {
                    Amplify.Logging.default.error("Error flushing logs with error \(error.localizedDescription)")
                    let payload = HubPayload(eventName: HubPayload.EventName.Logging.flushLogFailure, context: error.localizedDescription)
                    Amplify.Hub.dispatch(to: HubChannel.logging, payload: payload)
                    try strongBatch.complete()
                }
            }
        }
    }

    private func userIdentifierDidChange() {
        resetCurrentLogs()
        updateSession()
        updateConsumer()
        connectProducerAndConsumer()
    }

    private func updateSession() {
        do {
            self.session = try AWSCloudWatchLoggingSession(category: self.category,
                                                           namespace: self.namespace,
                                                           logLevel: self.logLevel,
                                                           userIdentifier: self.userIdentifier,
                                                           localStoreMaxSizeInMB: self.localStoreMaxSizeInMB)
        } catch {
            self.session = nil
            print(error)
        }
    }

    func setCurrentUser(identifier: String?) {
        self.userIdentifier = identifier
    }

    func flushLogs() async throws {
        guard let logBatches = try await session?.logger.getLogBatches() else { return }

        for batch in logBatches {
            try await consumeLogBatch(batch)
        }
    }

    private func consumeLogBatch(_ batch: LogBatch) async throws {
        // Check if consumer exists before trying to use it
        guard let consumer = self.consumer else {
            // If consumer is nil, still mark the batch as completed to prevent memory leaks
            try batch.complete()
            return
        }
        
        do {
            try await consumer.consume(batch: batch)
        } catch {
            Amplify.Logging.default.error("Error flushing logs with error \(error.localizedDescription)")
            let payload = HubPayload(eventName: HubPayload.EventName.Logging.flushLogFailure, context: error.localizedDescription)
            Amplify.Hub.dispatch(to: HubChannel.logging, payload: payload)
            try batch.complete()
        }
    }

    private func resetCurrentLogs() {
        Task {
            do {
                try await session?.logger.resetLogs()
            } catch {
                Amplify.Logging.error("Error resetting logs with \(error)")
            }
        }
    }
}

extension AWSCloudWatchLoggingSessionController: Logger {
    func error(_ message: @autoclosure () -> String) {
        guard self.logFilter.canLog(withCategory: self.category, logLevel: .error, userIdentifier: self.userIdentifier) else { return }
        session?.logger.error(message())
    }

    func error(error: Error) {
        guard self.logFilter.canLog(withCategory: self.category, logLevel: .error, userIdentifier: self.userIdentifier) else { return }
        session?.logger.error(error: error)
    }

    func warn(_ message: @autoclosure () -> String) {
        guard self.logFilter.canLog(withCategory: self.category, logLevel: .warn, userIdentifier: self.userIdentifier) else { return }
        session?.logger.warn(message())
    }

    func info(_ message: @autoclosure () -> String) {
        guard self.logFilter.canLog(withCategory: self.category, logLevel: .info, userIdentifier: self.userIdentifier) else { return }
        session?.logger.info(message())
    }

    func debug(_ message: @autoclosure () -> String) {
        guard self.logFilter.canLog(withCategory: self.category, logLevel: .debug, userIdentifier: self.userIdentifier) else { return }
        session?.logger.debug(message())
    }

    func verbose(_ message: @autoclosure () -> String) {
        guard self.logFilter.canLog(withCategory: self.category, logLevel: .verbose, userIdentifier: self.userIdentifier) else { return }
        session?.logger.verbose(message())
    }
}
