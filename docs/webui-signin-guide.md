# Web UI Sign In Authentication Guide

## Overview
The AWS Amplify Auth category supports authenticating your users through a hosted web user interface. This guide explains the configuration options available for web UI sign-in, including the choice between ASWebAuthenticationSession and SFSafariViewController.

## Configuration Options

### Using ASWebAuthenticationSession (Default)
ASWebAuthenticationSession is the default and recommended approach for most applications:

```swift
let options = AuthWebUISignInRequest.Options()
try await Amplify.Auth.signInWithWebUI(options: options)
```

### Using SFSafariViewController
For applications that need to maintain cookie continuity with SFSafariViewController instances used elsewhere in the app:

```swift
let options = AuthWebUISignInRequest.Options.preferSafariViewController()
try await Amplify.Auth.signInWithWebUI(options: options)
```

### Private Sessions
You can enable private browsing sessions with either authentication method:

```swift
let options = AuthWebUISignInRequest.Options.preferPrivateSession()
try await Amplify.Auth.signInWithWebUI(options: options)
```

## Migration Guide
If you're migrating from an earlier version that only supported ASWebAuthenticationSession:

1. No changes are required if you want to continue using ASWebAuthenticationSession
2. To switch to SFSafariViewController, update your sign-in call to use `.preferSafariViewController()`

## Platform Support
- ASWebAuthenticationSession: Supported on iOS, macOS, and visionOS
- SFSafariViewController: Supported on iOS and visionOS only