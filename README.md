# NnVersionKit

![Build Status](https://github.com/nikolainobadi/NnVersionKit/actions/workflows/ci.yml/badge.svg)
![Swift Version](https://badgen.net/badge/swift/6.0%2B/purple)
![Platforms](https://img.shields.io/badge/platforms-iOS%2017%2B%20%7C%20macOS%2014%2B-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## Overview

**NnVersionKit** is a lightweight Swift package for detecting app version changes. It helps compare the locally installed version of your app with the version available on the App Store, allowing you to prompt users for updates based on major, minor, or patch version differences.

This package is ideal for developers who want fine-grained control over version update logic in SwiftUI-based apps.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic SwiftUI Integration](#basic-swiftui-integration)
  - [Custom Version Loaders](#custom-version-loaders)
  - [Comparing Version Numbers Manually](#comparing-version-numbers-manually)
- [About This Project](#about-this-project)
- [Contributing](#contributing)
- [License](#license)

## Features

- Retrieve current app version from the local `Info.plist`
- Fetch latest version info from the App Store
- Compare versions at major, minor, or patch level
- Async/await-powered version loading
- SwiftUI view modifiers to trigger update UIs
- Fully tested with lightweight, modern syntax

## Installation

```swift
.package(url: "https://github.com/nikolainobadi/NnVersionKit", from: "1.0.0")
```

## Usage

### Basic SwiftUI Integration
Just pass in the main `Bundle` of your app to compare the device version with the current version from the App Store.

By default, the version number being compared will be the **major** number, but you can pass in a different `VersionNumberType`if you want updates to trigger for **minor** or **patch** changes.
```swift
import NnVersionKit

var body: some View {
    ContentView()
        .checkingAppVersion(bundle: .main, versionNumberUpdateType: .major) { 
            Text("Please update the app!")
        }
}
```

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
Your custom implemntation would simply have to return a `VersionNumber` to conform to `VersionLoader`:

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
let updateRequired = VersionNumberHandler.versionUpdateIsRequired(deviceVersion: deviceVersion, onlineVersion: onlineVersion)

print("version update required:", updateRequired)
```

## Contributing

Feel free to [open an issue](https://github.com/nikolainobadi/NnVersionKit/issues) if you have any suggestions or feedback.

For larger changes, consider opening a discussion first.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
