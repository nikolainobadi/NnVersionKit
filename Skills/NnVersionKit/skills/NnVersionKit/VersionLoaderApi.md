# VersionLoader API

Version loading and SwiftUI integration: the `VersionLoader` protocol, its two built-in implementations, and the `checkingAppVersion` View modifiers.

---

## Protocol: VersionLoader

Contract for asynchronously loading a `VersionNumber` from any source.

```swift
public protocol VersionLoader: Sendable {
    func loadVersionNumber() async throws -> VersionNumber
}
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `loadVersionNumber() async throws` | `VersionNumber` | Implementations must asynchronously load and return a version number. |

### Usage Example

```swift
struct RemoteConfigVersionLoader: VersionLoader {
    func loadVersionNumber() async throws -> VersionNumber {
        let versionString = try await fetchMinimumVersionString()
        return try VersionNumberHandler.makeNumber(from: versionString)
    }
}
```

### VersionLoader Implementations

| Implementation | Key Difference |
|----------------|----------------|
| `DeviceBundleVersionLoader` | Synchronous Info.plist read wrapped in async — no real I/O. Throws `.missingDeviceVersionString` when the key is absent or not a String. |
| `AppStoreVersionLoader` | Real network I/O via `URLSession.shared` against the iTunes Lookup API. Throws `.invalidBundleId` for a nil bundle ID; `.missingDeviceVersionString` when the JSON shape doesn't match. |
| `StaticVersionLoader` | Returns a fixed `VersionNumber`. `init(version:)` or throwing `init(versionString:)`. For UI-test seeding and any already-known version source. See `TestingApi.md`. |

All three delegate string parsing to `VersionNumberHandler.makeNumber(from:)` — `StaticVersionLoader` only in its `init(versionString:)` — so they throw `VersionKitError.missingNumber` on non-numeric segments and produce identical `VersionNumber` semantics for the same string.

---

## Class: AppStoreVersionLoader

Fetches the published app version from Apple's iTunes Lookup API.

```swift
public final class AppStoreVersionLoader
extension AppStoreVersionLoader: VersionLoader
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `convenience init(bundleId: String?, debugEnabled: Bool = false)` | Creates a loader for the given bundle identifier, backed by `URLSession.shared`. |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `loadVersionNumber() async throws` | `VersionNumber` | Fetches and parses the current App Store version. |

### Usage Example

```swift
let loader = AppStoreVersionLoader(bundleId: Bundle.main.bundleIdentifier)
let appStoreVersion = try await loader.loadVersionNumber()
```

### Internal Flow

`loadVersionNumber()` builds `https://itunes.apple.com/lookup?bundleId=<id>` (no URL encoding applied), fetches via `URLSession.shared` (no custom timeout, no retry), parses with `JSONSerialization`, and reads `results.first?["version"]`. The version string is then parsed by `VersionNumberHandler.makeNumber(from:)`.

Error paths:
- `bundleId == nil` or URL construction fails → `VersionKitError.invalidBundleId`
- Missing or empty `results` array, or non-matching JSON shape → `VersionKitError.missingDeviceVersionString`
- Non-numeric version string → `VersionKitError.missingNumber`
- Network failures propagate **unwrapped** — they are not converted to `VersionKitError`

---

## Class: DeviceBundleVersionLoader

Reads the installed app version from a bundle's Info.plist.

```swift
public final class DeviceBundleVersionLoader
extension DeviceBundleVersionLoader: VersionLoader
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(bundle: Bundle, debugEnabled: Bool = false)` | Creates a loader reading from the given bundle (typically `.main`). |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `loadVersionNumber() async throws` | `VersionNumber` | Reads and parses `CFBundleShortVersionString` from the bundle. |

### Usage Example

```swift
let loader = DeviceBundleVersionLoader(bundle: .main)
let installedVersion = try await loader.loadVersionNumber()
```

### Internal Flow

Reads `bundle.infoDictionary[.bundleVersionKey]` and casts to `String`. A nil dictionary, an absent key, or a non-String value (e.g. the plist stores `123` as a number) all throw `VersionKitError.missingDeviceVersionString`. On success it delegates parsing entirely to `VersionNumberHandler.makeNumber(from:)` — the loader itself does no parsing.

---

## Extension: String

```swift
public extension String {
    static var bundleVersionKey: String { "CFBundleShortVersionString" }
}
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `bundleVersionKey` (static) | `String` | The Info.plist key read by `DeviceBundleVersionLoader`. Useful for seeding mock bundles in tests: `[.bundleVersionKey: "1.2.3"]`. |

---

## Extension: View — checkingAppVersion

The SwiftUI entry points. All four overloads attach a version check that runs when the view appears; the two that take an `updateView` **replace the modified content entirely** with it when an update is required, and the two report-only overloads never replace content at all.

```swift
public extension View {
    func checkingAppVersion<UpdateView: View>(
        bundle: Bundle,
        onlineVersionLoader: VersionLoader? = nil,
        updatePolicy: VersionUpdatePolicy = .majorOnly,
        debugEnabled: Bool = false,
        enableUITestSeeding: Bool = false,
        onStatus: VersionStatusHandler? = nil,
        onError: ((Error) -> Void)? = nil,
        @ViewBuilder updateView: @escaping () -> UpdateView
    ) -> some View

    func checkingAppVersion<UpdateView: View>(
        deviceVersionLoader: VersionLoader,
        onlineVersionLoader: VersionLoader,
        updatePolicy: VersionUpdatePolicy = .majorOnly,
        debugEnabled: Bool = false,
        onStatus: VersionStatusHandler? = nil,
        onError: ((Error) -> Void)? = nil,
        @ViewBuilder updateView: @escaping () -> UpdateView
    ) -> some View

    // Report-only overloads — no updateView; the content is never replaced.
    func checkingAppVersion(
        bundle: Bundle,
        onlineVersionLoader: VersionLoader? = nil,
        updatePolicy: VersionUpdatePolicy = .majorOnly,
        debugEnabled: Bool = false,
        enableUITestSeeding: Bool = false,
        onError: ((Error) -> Void)? = nil,
        onStatus: @escaping VersionStatusHandler
    ) -> some View

    func checkingAppVersion(
        deviceVersionLoader: VersionLoader,
        onlineVersionLoader: VersionLoader,
        updatePolicy: VersionUpdatePolicy = .majorOnly,
        debugEnabled: Bool = false,
        onError: ((Error) -> Void)? = nil,
        onStatus: @escaping VersionStatusHandler
    ) -> some View
}
```

**Two ways to handle an update — pick by whether you pass `updateView`:**

1. **Provide `updateView`** → NnVersionKit replaces the content with it when the status is `.updateRequired`. `onStatus` is optional here, for the soft `.updateAvailable` nudge.
2. **Omit `updateView` (report-only overload)** → the content is never replaced and `onStatus` (required) reports every state, so the client presents the forced update and any soft prompt itself. `VersionNumber: Identifiable` makes `.sheet(item:)` / `.fullScreenCover(item:)` straightforward.

Notes:
- `onStatus` fires after every check with the resolved `VersionUpdateStatus` and the online `VersionNumber`.
- `enableUITestSeeding` (bundle overloads) is opt-in and off by default. When `true`, a device/online version seeded via `NnVersionKitEnvironment` overrides the corresponding loader. See `TestingApi.md`.

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `checkingAppVersion(bundle:onlineVersionLoader:updatePolicy:debugEnabled:enableUITestSeeding:onStatus:onError:updateView:)` | `some View` | Convenience overload: device version from the bundle's Info.plist; online version from the App Store (default) or a custom loader. Presents `updateView`. |
| `checkingAppVersion(deviceVersionLoader:onlineVersionLoader:updatePolicy:debugEnabled:onStatus:onError:updateView:)` | `some View` | Full-control overload: both loaders supplied explicitly. Presents `updateView`. |
| `checkingAppVersion(bundle:onlineVersionLoader:updatePolicy:debugEnabled:enableUITestSeeding:onError:onStatus:)` | `some View` | Report-only bundle overload: no `updateView`, `onStatus` required, content never replaced. |
| `checkingAppVersion(deviceVersionLoader:onlineVersionLoader:updatePolicy:debugEnabled:onError:onStatus:)` | `some View` | Report-only two-loader overload: no `updateView`, `onStatus` required, content never replaced. |

### Usage Example

```swift
var body: some View {
    ContentView()
        .checkingAppVersion(bundle: .main, updatePolicy: .majorOnly) {
            Text("Please update the app!")
        }
}
```

### Internal Flow

The bundle overloads construct `DeviceBundleVersionLoader(bundle:)` for the device side and default the online side to `AppStoreVersionLoader(bundleId: bundle.bundleIdentifier)`. The check runs in a `.task` when the view appears: device load first, then online load (sequential, not concurrent), then `VersionNumberHandler.versionStatus(...policy:)`, whose result is published to `onStatus` and drives the forced-update branch.

- On the `updateView` overloads, a status of `.updateRequired` makes `updateView()` **replace** the content — the original view (and its `.task`) is removed from the hierarchy, making this a forced-update gate rather than an overlay. The report-only overloads leave the content in place for every status.
- If either loader throws, `onError` is invoked and the update view is **not** shown — content stays visible.
- If `bundle.bundleIdentifier` is nil, the default App Store loader throws `VersionKitError.invalidBundleId` at check time, surfacing through `onError`.

---

## Best Practices

- **Depend on `VersionLoader`, not concrete loaders** — both built-in loaders and your custom sources (Firebase, your own API) interchange freely behind the protocol; tests inject a simple mock conformer.
- **Primary entry point** — `.checkingAppVersion(bundle: .main) { ... }` covers the standard App-Store-published app; reach for the two-loader overload only for non-App-Store distribution or custom sources.
- **The update view replaces content** — it is a hard gate, not a banner. Content is absent from the hierarchy while the update prompt shows.
- **Errors never trigger the update view** — a failed check fails open (content stays). Supply `onError` if silent failure is not acceptable.
- **No timeout on the App Store fetch** — `URLSession.shared` defaults apply; network errors propagate unwrapped rather than as `VersionKitError`.
- **Pass a custom `onlineVersionLoader` in the bundle overload** to override the App Store lookup — useful for TestFlight builds, enterprise distribution, or staged rollouts.
