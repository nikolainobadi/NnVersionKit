# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/nikolainobadi/NnVersionKit/compare/1.1.0...HEAD
[1.1.0]: https://github.com/nikolainobadi/NnVersionKit/compare/v1.0.0...1.1.0
[1.0.0]: https://github.com/nikolainobadi/NnVersionKit/releases/tag/v1.0.0
