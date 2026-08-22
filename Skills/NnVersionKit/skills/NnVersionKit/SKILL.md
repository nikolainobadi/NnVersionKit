---
name: nnversionkit
description: NnVersionKit Swift API reference for app version checking and update prompts. USE WHEN checking app version, forced update UI, checkingAppVersion view modifier, VersionUpdatePolicy, forcing updates by version range, update available status, VersionUpdateStatus, onStatus callback, UI test version seeding, StaticVersionLoader, VersionLoader, AppStoreVersionLoader, DeviceBundleVersionLoader, VersionNumber comparison, App Store version lookup, VersionKitError.
user-invocable: true
---

# NnVersionKit

Swift package that detects when an app update is available by comparing the installed version against the App Store (or any custom source), with a SwiftUI view modifier that swaps in an update prompt.

**Dependency:** `https://github.com/nikolainobadi/NnVersionKit.git` (from: `2.0.0`)
**Platforms:** iOS 17+, macOS 14+ | **Swift:** 6.0

This skill lives inside the NnVersionKit repo at `Skills/NnVersionKit/`, so the API it documents is the API in `Sources/` alongside it.

## Context Files

| File | Purpose | Load When |
|------|---------|-----------|
| `VersionLoaderApi.md` | VersionLoader protocol, AppStoreVersionLoader, DeviceBundleVersionLoader, SwiftUI `checkingAppVersion` modifiers | Integrating version checks, building custom loaders, adding update prompts |
| `VersionModelApi.md` | VersionNumber, VersionUpdatePolicy, VersionUpdateStatus, VersionKitError, VersionNumberHandler | Parsing or comparing version numbers, choosing an update policy, classifying update status, handling errors |
| `TestingApi.md` | StaticVersionLoader, NnVersionKitEnvironment, `enableUITestSeeding` | Driving the update UI deterministically in UI tests by seeding device/online versions |
| `Migration.md` | 1.x → 2.0.0 migration: `VersionNumberType` → `VersionUpdatePolicy`, level-to-policy mapping, before/after snippets | Upgrading an existing integration from NnVersionKit 1.x to 2.0.0 |

## Quick Reference

- `View.checkingAppVersion(bundle: .main) { UpdateView() }` — primary SwiftUI entry point; **replaces** content with the update view when an update is required
- `View.checkingAppVersion(bundle: .main) { status, version in ... }` — report-only overload; presents nothing, hands every status to `onStatus` so the client owns all UI
- `VersionLoader` protocol (`loadVersionNumber() async throws -> VersionNumber`) — conform for custom version sources
- `AppStoreVersionLoader(bundleId:)` — fetches the published version via the iTunes Lookup API
- `DeviceBundleVersionLoader(bundle:)` — reads `CFBundleShortVersionString` from Info.plist
- `VersionUpdatePolicy` — `.majorOnly` (default), `.minor(allowedPreviousVersions:)`, `.patch(allowedPreviousVersions:)`; a new major always forces, sub-levels tolerate a window of recent releases
- `VersionNumberHandler.versionUpdateIsRequired(...policy:)` — returns whether an update is required under a `VersionUpdatePolicy`
- `VersionUpdateStatus` — `.upToDate` / `.updateAvailable` / `.updateRequired`; delivered via the `onStatus` callback on `checkingAppVersion`, or computed directly with `VersionNumberHandler.versionStatus(...)`
- `StaticVersionLoader(version:)` / `NnVersionKitEnvironment` — fixed-version loader and launch-environment seeding for UI tests (`enableUITestSeeding`)
- `VersionKitError` — `.missingNumber`, `.invalidBundleId`, `.missingDeviceVersionString`, `.unableToFetchVersionFromAppStore`

## Examples

- "Add a forced update prompt when a new App Store version ships" -> Loads `VersionLoaderApi.md`
- "Compare two version strings to decide if an update is required" -> Loads `VersionModelApi.md`
- "Create a custom VersionLoader backed by Firebase Remote Config" -> Loads `VersionLoaderApi.md`
- "Show a soft 'update available' banner when the user is behind but not forced" -> Loads `VersionModelApi.md` + `VersionLoaderApi.md`
- "Seed app versions to UI test the forced update screen" -> Loads `TestingApi.md`
- "Upgrade my app from NnVersionKit 1.x to 2.0.0" -> Loads `Migration.md`
