# amplify-swift

> **DEPRECATED — RECOMMEND DELETION**
>
> This fork is **NOT used** by the iOS app. `SA-User-MobileApp-iOS` depends on
> **upstream `aws-amplify/amplify-swift` directly** via Swift Package Manager.
> The fork is 5+ months out of date, has no bFAN CI/CD, and its git history is
> corrupted/shallow. The only customization ever made was removing
> `handleHostedUIRedirect`, which is no longer relevant. This repo should be
> archived and removed from the bfan-ai submodule list.

## What This Is

A stale, unused fork of the AWS Amplify Library for Swift. The iOS app (`SA-User-MobileApp-iOS`) consumes the **upstream AWS package directly** — not this fork.

**Only known customization:** Removal of `handleHostedUIRedirect` (no longer needed).

## Status

| Fact | Detail |
|------|--------|
| **Used by iOS app?** | No — app points to upstream `aws-amplify/amplify-swift` |
| **Last synced with upstream** | 5+ months ago |
| **bFAN CI/CD** | None |
| **Git history** | Corrupted / shallow clone |
| **Custom changes** | Removed `handleHostedUIRedirect` only |
| **Recommendation** | Archive and delete from bfan-ai hub |

## Tech Stack

- **Language**: Swift 5.9+
- **Platforms**: iOS 13+, macOS 12+, tvOS 13+, watchOS 9+, visionOS 1+ (preview)
- **Package Manager**: Swift Package Manager
- **Key Dependencies**:
  - `aws-sdk-swift` (1.5.18) — underlying AWS SDK
  - `SQLite.swift` (0.15.3) — DataStore persistence
  - `amplify-swift-utils-notifications` — push notification utilities

## Dependencies

**Upstream**: Fork of AWS's official `amplify-swift` SDK.

**Consumed by**: Nothing. The iOS app uses upstream directly.

## Gotchas

- **This fork is dead weight.** Do not invest time updating or syncing it.
- **Do not add bFAN customizations here.** If Amplify customization is ever needed, evaluate whether upstream configuration or a local Swift package overlay is sufficient before reviving this fork.
- **Git history is unreliable** — shallow clone with missing commits. Do not trust `git log` or `git blame` in this repo.
