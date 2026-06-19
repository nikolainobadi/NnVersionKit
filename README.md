# NnVersionKit

![Build Status](https://github.com/nikolainobadi/NnVersionKit/actions/workflows/ci.yml/badge.svg)
![Swift Version](https://badgen.net/badge/swift/6.0%2B/purple)
![Platforms](https://img.shields.io/badge/platforms-iOS%2017%2B%20%7C%20macOS%2014%2B-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## Overview

**NnVersionKit** is a lightweight Swift package for detecting app version changes. It helps compare the locally installed version of your app with the version available on the App Store, prompting users to update based on a configurable policy — force on every new major version, or tolerate a window of recent minor/patch releases before requiring an update.

This package is ideal for developers who want fine-grained control over version update logic in SwiftUI-based apps.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic SwiftUI Integration](#basic-swiftui-integration)
  - [Custom Version Loaders](#custom-version-loaders)
  - [Comparing Version Numbers Manually](#comparing-version-numbers-manually)
  - [Debug Logging](#debug-logging)
- [Contributing](#contributing)
- [License](#license)

## Features

- Retrieve current app version from the local `Info.plist`
- Fetch latest version info from the App Store
- Force updates by policy — major-only, or tolerate a window of recent minor/patch releases
- Async/await-powered version loading
- SwiftUI view modifiers to trigger update UIs
- Opt-in debug logging for troubleshooting version checks
- Fully tested with lightweight, modern syntax

## Installation

```swift
.package(url: "https://github.com/nikolainobadi/NnVersionKit", from: "2.0.0")
```

## Usage

### Basic SwiftUI Integration
Just pass in the main `Bundle` of your app to compare the device version with the current version from the App Store.

By default, only a new **major** version forces an update (`.majorOnly`). Pass a different `VersionUpdatePolicy` to also force updates once the device falls too far behind at the **minor** or **patch** level.
```swift
import NnVersionKit

var body: some View {
    ContentView()
        .checkingAppVersion(bundle: .main, updatePolicy: .majorOnly) {
            Text("Please update the app!")
        }
}
```

#### Tolerating a range of recent versions
`.minor` and `.patch` let clients stay a few releases behind the latest before an update is forced. A new major version always forces an update under every policy.

```swift
// Latest is 4.35.0. Force an update only once the device is more than 4 minor
// releases behind — i.e. anything older than 4.31.x. Patch differences are ignored.
.checkingAppVersion(bundle: .main, updatePolicy: .minor(allowedPreviousVersions: 4)) {
    Text("Please update the app!")
}
```

`allowedPreviousVersions: 0` requires the device to be on the latest version at that level. `.patch` additionally forces an update on any new minor version, since patch numbers reset per minor.

### Custom Version Loaders
If you store your local device version outside of the main `Bundle`, and/or your app isn't on the App Store (or you store the 'online version number' elsewhere), you can simply implement your own `VersionLoader`s to pass into the view modifier.

```swift

let deviceLoader: VersionLoader // your custom implementation
let onlineLoader: VersionLoader // your custom implementation

var body: some View {
    ContentView()
        .checkingAppVersion(deviceVersionLoader: deviceLoader, onlineVersionLoader: onlineLoader) {
            Text("Please update the app!")
        }
}
```
Your custom implementation would simply have to return a `VersionNumber` to conform to `VersionLoader`:

```swift
public protocol VersionLoader: Sendable {
    func loadVersionNumber() async throws -> VersionNumber
}
```

### Comparing Version Numbers Manually
For non-SwiftUI developers, you can use a default `VersionLoader` combined with `VersionNumberHandler` to compare versions manually.

```swift
let deviceVersionLoader = DeviceBundleVersionLoader(bundle: .main)
let onlineVersionLoader = AppStoreVersionLoader(bundleId: Bundle.main.bundleIdentifier)

let deviceVersion = try await deviceVersionLoader.loadVersionNumber()
let onlineVersion = try await onlineVersionLoader.loadVersionNumber()
let updateRequired = VersionNumberHandler.versionUpdateIsRequired(deviceVersion: deviceVersion, onlineVersion: onlineVersion, policy: .majorOnly)

print("version update required:", updateRequired)
```

### Debug Logging
Version checks are completely silent by default — nothing is printed to the console. Pass `debugEnabled: true` to print detailed version check information, useful for troubleshooting why an update prompt is (or isn't) appearing.

```swift
var body: some View {
    ContentView()
        .checkingAppVersion(bundle: .main, debugEnabled: true) {
            Text("Please update the app!")
        }
}
```

Console output when enabled:

```
[NnVersionKit] Starting version check (policy: majorOnly)
[NnVersionKit] Device version string from bundle: 1.2.3
[NnVersionKit] Parsed version string '1.2.3' into 1.2.3
[NnVersionKit] Loaded device version: 1.2.3
[NnVersionKit] Fetching App Store version from https://itunes.apple.com/lookup?bundleId=com.example.app
[NnVersionKit] Received 4821 bytes from App Store lookup
[NnVersionKit] App Store version string: 2.0.0
[NnVersionKit] Parsed version string '2.0.0' into 2.0.0
[NnVersionKit] Loaded online version: 2.0.0
[NnVersionKit] Comparing device 1.2.3 to online 2.0.0 under policy majorOnly (update required: true)
[NnVersionKit] Version update required: true
```

Failure paths are logged as well (invalid bundle ID, missing `Info.plist` version, unparseable responses). Errors are always delivered to your `onError` handler regardless of the debug setting.

The same flag is available when constructing loaders directly:

```swift
let deviceVersionLoader = DeviceBundleVersionLoader(bundle: .main, debugEnabled: true)
let onlineVersionLoader = AppStoreVersionLoader(bundleId: Bundle.main.bundleIdentifier, debugEnabled: true)
```

## Contributing

Feel free to [open an issue](https://github.com/nikolainobadi/NnVersionKit/issues) if you have any suggestions or feedback.

For larger changes, consider opening a discussion first.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
