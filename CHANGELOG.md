# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.1] - 2026-08-17

No changes to the package API.

### Added
- The Claude Code API reference skill now ships from this repository at `Skills/NnVersionKit/`, published through the `nn-swift-skills` marketplace and pinned to a release tag. It previously lived in a separate repository, where it could drift out of step with the API it documents. A CI check now fails any pull request that changes the public API without also updating the skill.

### Fixed
- The "Responding to an Available Update" example in the README applied `checkingAppVersion` twice. Each application runs an independent check with its own loaders, so the snippet performed two App Store lookups and stacked two update gates, and the second reverted to the default `.majorOnly` policy. It now passes `updatePolicy` and `onStatus` to a single modifier.

## [2.0.0] - 2026-06-19

### Added
- `VersionUpdatePolicy`, a public enum controlling how far behind the latest version a device may fall before an update is forced. `.majorOnly` forces an update only on a new major version; `.minor(allowedPreviousVersions:)` and `.patch(allowedPreviousVersions:)` additionally force an update once the device falls more than the allowed number of minor or patch releases behind the latest.
- `VersionUpdateStatus` and a general `onStatus` callback on both `checkingAppVersion` view modifiers, surfacing whether the device is `upToDate`, behind but within policy (`updateAvailable`), or `updateRequired`. Use it to show a non-blocking "update available" prompt when a forced update is not warranted. The callback type is the public `VersionStatusHandler` typealias. `VersionNumberHandler.versionStatus(...)` exposes the same classification for non-SwiftUI callers, and `VersionNumber` now conforms to `Comparable` and `Identifiable`.
- Report-only `checkingAppVersion` overloads that omit `updateView`: the content is never replaced and `onStatus` reports every state, so a client can present the forced update (and any soft prompt) entirely on its own. Provide an `updateView` to let NnVersionKit present the forced screen, or omit it to own all presentation — `VersionNumber: Identifiable` makes `.sheet(item:)` / `.fullScreenCover(item:)` straightforward.
- `StaticVersionLoader`, a `VersionLoader` returning a fixed version, plus `NnVersionKitEnvironment` for seeding the device and/or online version through the launch environment in UI tests. The bundle `checkingAppVersion` overload gains an opt-in `enableUITestSeeding` flag that applies the seeded versions. Seeding only ever sets its own namespaced keys, so it composes with other launch-environment seeders.

### Changed
- **Breaking:** The `checkingAppVersion` view modifiers now take an `updatePolicy: VersionUpdatePolicy` parameter (default `.majorOnly`) in place of the previous `versionNumberUpdateType: VersionNumberType` parameter.
- **Breaking:** `VersionNumberHandler.versionUpdateIsRequired(...)` now takes a `policy: VersionUpdatePolicy` argument instead of `selectedVersionNumberType: VersionNumberType`.

### Removed
- **Breaking:** `VersionNumberType` is no longer part of the public API. Replace `.major`, `.minor`, and `.patch` usage with the corresponding `VersionUpdatePolicy` cases.

## [1.1.0] - 2026-06-06

### Added
- Opt-in debug logging via a `debugEnabled` flag on the `checkingAppVersion` view modifiers, `DeviceBundleVersionLoader`, `AppStoreVersionLoader`, and `VersionNumberHandler`. Logs version loading, parsing, and comparison details to the console. Silent by default.

### Changed
- `VersionCheckViewModel` migrated from `ObservableObject` to the `@Observable` macro (internal; no public API change).
- Errors are no longer printed to the console unconditionally — they print only when debug logging is enabled, and are always delivered to the `onError` handler.
- Unit tests rewritten with behavior-driven, backtick-escaped test names (Swift Testing raw identifiers).
- CI updated to the macOS 26 runner with Xcode 26.2 (Swift 6.2).

## [1.0.0] - 2025-04-04

### Added
- `VersionNumber` model representing semantic versions (major.minor.patch).
- `VersionNumberHandler` for parsing version strings and comparing versions at major, minor, or patch level.
- `VersionLoader` protocol with async/await version loading.
- `DeviceBundleVersionLoader` for reading the app version from the bundle's `Info.plist`.
- `AppStoreVersionLoader` for fetching the latest version from the iTunes Lookup API.
- `checkingAppVersion` SwiftUI view modifiers to present an update view when a newer version is available.
- Optional `onError` handler for version check failures.
- Unit test suite and GitHub Actions CI workflow.

[Unreleased]: https://github.com/nikolainobadi/NnVersionKit/compare/2.0.1...HEAD
[2.0.1]: https://github.com/nikolainobadi/NnVersionKit/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/nikolainobadi/NnVersionKit/compare/1.1.0...2.0.0
[1.1.0]: https://github.com/nikolainobadi/NnVersionKit/compare/v1.0.0...1.1.0
[1.0.0]: https://github.com/nikolainobadi/NnVersionKit/releases/tag/v1.0.0
