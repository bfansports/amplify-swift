# amplify-swift

## What This Is

bFAN's fork of the AWS Amplify Library for Swift. This provides the iOS app with declarative interfaces for AWS services (Auth, API, Storage, DataStore, Push Notifications, etc.). The fork contains custom modifications specific to bFAN's integration needs that differ from the upstream AWS SDK.

<!-- Ask: What specific modifications does bFAN maintain in this fork vs upstream? -->

## Tech Stack

- **Language**: Swift 5.9+
- **Platforms**: iOS 13+, macOS 12+, tvOS 13+, watchOS 9+, visionOS 1+ (preview)
- **Package Manager**: Swift Package Manager
- **Key Dependencies**:
  - `aws-sdk-swift` (1.5.18) — underlying AWS SDK
  - `SQLite.swift` (0.15.3) — DataStore persistence
  - `amplify-swift-utils-notifications` — push notification utilities

## Quick Start

```bash
# Setup
# Clone is already done as a submodule in bfan-ai hub

# Build the package
swift build

# Run tests
swift test

# Generate documentation
jazzy --config .jazzy.yaml
```

<!-- Ask: Does bFAN have CI/CD for this fork? How are updates merged from upstream AWS? -->

## Project Structure

```
Amplify/                    # Core Amplify interfaces and protocols
AmplifyPlugins/             # Service plugins (Auth, API, Storage, etc.)
  Core/AWSPluginsCore/      # Shared AWS plugin utilities
  Core/AmplifyCredentials/  # Credential management
AmplifyTests/               # Unit tests
AmplifyFunctionalTests/     # Integration tests
AmplifyTestCommon/          # Shared test utilities
AmplifyTestApp/             # Example iOS app for testing
fastlane/                   # iOS CI/CD automation
CircleciScripts/            # CircleCI build scripts
```

## Dependencies

**Upstream dependency**: This is a fork of AWS's official `amplify-swift` SDK.

**Consumed by**:
- `SA-User-MobileApp-iOS` — main white-label iOS app
- Possibly other iOS projects in the bFAN ecosystem

**External services**:
- AWS Cognito (Authentication)
- AWS AppSync (GraphQL API)
- AWS S3 (Storage)
- AWS DynamoDB (DataStore)
- AWS Pinpoint (Analytics)
- AWS SNS/APNS (Push Notifications)

## API / Interface

This library is consumed as a Swift Package Manager dependency. The iOS app imports specific Amplify modules:

```swift
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin
import AWSDataStorePlugin
import AWSPinpointPushNotificationsPlugin
```

<!-- Ask: Which Amplify plugins does the bFAN iOS app actually use? -->

## Key Patterns

- **Plugin Architecture**: Amplify uses a plugin-based system where each AWS service is a separate plugin registered at runtime
- **Category-based APIs**: Services are grouped into categories (Auth, API, Storage, DataStore, Predictions, Analytics, Geo)
- **Async/Await Support**: Modern Swift concurrency alongside legacy Combine/callback APIs
- **Offline-first DataStore**: Syncs with cloud when online, works offline when disconnected

<!-- Ask: Are there specific Amplify patterns or configurations that bFAN customizes? -->

## Environment

No environment variables required for the library itself. Configuration is provided by the consuming iOS app via `amplifyconfiguration.json`.

## Deployment

This is a library dependency, not a deployed service. Updates to the fork require:

1. Make changes in a feature branch
2. Test with the iOS app as a local package override
3. Merge to `main` via PR
4. Update the iOS app's `Package.swift` to reference the new commit SHA or tag

<!-- Ask: Does bFAN tag releases of this fork? How does the iOS app pin to specific versions? -->

## Testing

- **Framework**: XCTest (built-in Swift testing)
- **Run command**: `swift test`
- **Coverage**: Reported via Codecov (see `.codecov.yml`)
- **Functional tests**: `AmplifyFunctionalTests/` — requires AWS credentials and infrastructure

<!-- Ask: Does bFAN run the functional tests? Do we have AWS test infrastructure for this? -->

## Gotchas

- **Swift version lock**: The minimum Swift version is tied to the minimum Xcode version allowed by Apple for App Store submission. Amplify Swift typically updates this within 60 days of Apple's annual Xcode update (usually April).
- **Forked dependency**: When merging upstream changes from AWS, conflict resolution can be complex. Document bFAN-specific changes clearly.
- **Platform support**: visionOS is still in preview. Don't rely on it for production.
- **Breaking changes**: Amplify uses semantic versioning, but new cases added to public enums are considered non-breaking. Client code should handle unknown cases defensively.

<!-- Ask: What's the process for syncing upstream changes from AWS into the bFAN fork? Who owns that? -->
