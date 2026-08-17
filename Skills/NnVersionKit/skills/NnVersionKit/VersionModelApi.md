# VersionModel API

Version values, update policies, errors, and the parsing/comparison utility.

---

## Struct: VersionNumber

Value type representing a three-component semantic version.

```swift
public struct VersionNumber: Equatable, Comparable, Sendable, Identifiable
```

`Comparable` orders versions lexicographically by major, then minor, then patch, so `device < online` is a holistic "is the device behind" check. `Identifiable` (`id` is `stringFormat`) lets a version drive `.sheet(item:)` / `.fullScreenCover(item:)` when a client presents the update UI itself.

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(majorNum: Int, minorNum: Int, patchNum: Int)` | Creates a version from its three components. |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `majorNum` | `Int` | The major version component. |
| `minorNum` | `Int` | The minor version component. |
| `patchNum` | `Int` | The patch version component. |
| `stringFormat` | `String` | Computed. Always `"major.minor.patch"` (e.g. `"1.2.0"`), even when components are zero. |

### Usage Example

```swift
let device = VersionNumber(majorNum: 1, minorNum: 0, patchNum: 0)
let online = VersionNumber(majorNum: 2, minorNum: 0, patchNum: 0)
print(online.stringFormat) // "2.0.0"
```

---

## Enum: VersionUpdatePolicy

Determines how far behind the latest version a device may fall before an update is forced. A new **major** version always forces an update under every policy; sub-level cases additionally tolerate a window of recent releases.

```swift
public enum VersionUpdatePolicy: Sendable, Equatable
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `majorOnly` | — | **Default.** Only a new major version forces an update. Any number of minor/patch releases behind is allowed. |
| `minor` | `allowedPreviousVersions: Int` | Forces on a new major, or when the device is more than `allowedPreviousVersions` minor releases behind the latest. Patch differences are ignored. |
| `patch` | `allowedPreviousVersions: Int` | Forces on a new major, on any new minor, or when the device is more than `allowedPreviousVersions` patch releases behind the latest within the same minor. |

`allowedPreviousVersions: 0` requires the latest version at that level. Negative values are treated as `0`.

### Usage Example

```swift
// Latest is 4.35.0. Tolerate the 4 most recent minors (4.31.0–4.35.0);
// force an update on 4.30.x or older, and on any new major.
let policy: VersionUpdatePolicy = .minor(allowedPreviousVersions: 4)
// .majorOnly is the default throughout the package
```

---

## Enum: VersionUpdateStatus

The outcome of classifying the device version against the latest online version under a policy. Use it to distinguish a forced update from a softer "update available" nudge.

```swift
public enum VersionUpdateStatus: Sendable, Equatable
```

### Cases

| Case | Description |
|------|-------------|
| `upToDate` | Device is on the latest version or ahead of it. No update available. |
| `updateAvailable` | Device is behind, but the policy does not force an update. Surface a non-blocking prompt. |
| `updateRequired` | The policy forces an update (too far behind, or a full major behind). |

Delivered through the `onStatus` callback on the `checkingAppVersion` view modifiers, or computed directly with `VersionNumberHandler.versionStatus(...)`.

The callback type is the public `VersionStatusHandler` typealias:

```swift
public typealias VersionStatusHandler = (VersionUpdateStatus, VersionNumber) -> Void
```

---

## Enum: VersionKitError

All errors thrown by the package.

```swift
public enum VersionKitError: Error
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `missingNumber` | — | A version string contained a non-numeric segment (thrown by `VersionNumberHandler.makeNumber`). |
| `invalidBundleId` | — | Bundle ID was nil or the iTunes Lookup URL could not be built (`AppStoreVersionLoader`). |
| `missingDeviceVersionString` | — | Info.plist key absent/non-String (`DeviceBundleVersionLoader`), or the App Store JSON response didn't match the expected shape (`AppStoreVersionLoader`). |
| `unableToFetchVersionFromAppStore` | — | Declared but not thrown by the built-in loaders — available for custom `VersionLoader` conformers. Network failures from the App Store loader propagate as raw `URLSession` errors instead. |

### Usage Example

```swift
do {
    let version = try await loader.loadVersionNumber()
} catch VersionKitError.missingDeviceVersionString {
    // Info.plist or App Store response missing version data
} catch {
    // network or other errors, unwrapped
}
```

---

## Enum: VersionNumberHandler

Namespace enum providing static parsing and comparison utilities. Both built-in loaders delegate their parsing here.

```swift
public enum VersionNumberHandler
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `static makeNumber(from versionString: String, debugEnabled: Bool = false) throws` | `VersionNumber` | Parses a dot-separated version string into a `VersionNumber`. |
| `static versionUpdateIsRequired(deviceVersion: VersionNumber, onlineVersion: VersionNumber, policy: VersionUpdatePolicy, debugEnabled: Bool = false)` | `Bool` | Returns whether the online version requires an update under the given `VersionUpdatePolicy`. |
| `static versionStatus(deviceVersion: VersionNumber, onlineVersion: VersionNumber, policy: VersionUpdatePolicy, debugEnabled: Bool = false)` | `VersionUpdateStatus` | Classifies the device as `upToDate`, `updateAvailable` (behind but allowed), or `updateRequired`. |

### Usage Example

```swift
let device = try VersionNumberHandler.makeNumber(from: "1.2.3")
let online = try VersionNumberHandler.makeNumber(from: "1.4.0")

let updateRequired = VersionNumberHandler.versionUpdateIsRequired(
    deviceVersion: device,
    onlineVersion: online,
    policy: .minor(allowedPreviousVersions: 1)
) // true — device minor 2 is below the floor (4 - 1 = 3)
```

### Parsing Format

`makeNumber(from:)` splits on `"."` and converts each segment with `Int()`:

- **Partial strings are valid** — missing positions fill with zero: `"5"` → `5.0.0`, `"1.2"` → `1.2.0`.
- **No whitespace trimming** — `" 2"` or `"2 "` fails `Int()` conversion and throws `.missingNumber`.
- Any non-numeric segment (e.g. `"1.beta.3"`) throws `VersionKitError.missingNumber`.

### Comparison Logic

`versionUpdateIsRequired` evaluates the device against the latest online version under the chosen `VersionUpdatePolicy`. A new **major** always forces an update, and a device that is **ahead** never forces one.

| Policy | Returns true when |
|:-------|:------------------|
| `.majorOnly` | online major is higher (minor/patch ignored) |
| `.minor(N)` | online major is higher, **or** same major and `deviceMinor < onlineMinor − max(0, N)` (patch ignored) |
| `.patch(N)` | online major is higher, **or** same major and online minor is higher, **or** same major+minor and `devicePatch < onlinePatch − max(0, N)` |

- **Floor semantics:** `floor = latest − max(0, allowedPreviousVersions)` at the policy's level. The device forces an update only when it sits **below** the floor. A floor of `0` means "must be on the latest"; if the window exceeds available history (`floor ≤ 0`), no version is below it, so nothing forces.
- **Major dominance:** being a full major behind is outside any window — it always forces, even under `.minor`/`.patch`.
- **`.patch` has no minor tolerance:** any new minor forces, because patch numbers reset per minor (the N-patch window only counts within the same `major.minor`).
- **Device ahead never forces:** a higher device major/minor/patch resolves to `false` in every branch.

Worked example: latest `4.35.0` with `.minor(allowedPreviousVersions: 4)` → floor `31` → supported range `4.31.0`–`4.35.0`; a device on `4.30.x` or older forces an update.

---

## Best Practices

- **Parse with `VersionNumberHandler.makeNumber`** rather than splitting strings yourself — you get the same semantics (and errors) as the built-in loaders.
- **Pick the policy deliberately** — `.majorOnly` (the default everywhere) prompts only on major releases; `.minor`/`.patch` tighten the window the more you lower `allowedPreviousVersions`, down to `0` ("must be on the latest" at that level).
- **A new major always forces, device-ahead never forces** — the policy handles both directions, so a lower online major can never trigger a false update.
- **Partial version strings are normal** — App Store versions like `"2.1"` parse fine (`2.1.0`); don't pre-validate component count.
- **`debugEnabled` prints to stdout** with the `[NnVersionKit]` prefix via `print` — no os_log, no levels; keep it off in release builds.
