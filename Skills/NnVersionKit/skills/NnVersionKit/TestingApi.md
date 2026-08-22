# Testing API

Tools for driving the version check deterministically, primarily in UI tests.

---

## Struct: StaticVersionLoader

A `VersionLoader` that returns a fixed version. Useful for UI tests and for any source where the version is already known.

```swift
public struct StaticVersionLoader: VersionLoader {
    public init(version: VersionNumber)
    public init(versionString: String, debugEnabled: Bool = false) throws
    public func loadVersionNumber() async throws -> VersionNumber
}
```

- `init(versionString:)` parses with `VersionNumberHandler.makeNumber(from:)` and throws `VersionKitError.missingNumber` on a non-numeric segment.
- Pass it to the two-loader `checkingAppVersion` overload to fully control both sides.

---

## Enum: NnVersionKitEnvironment

Launch-environment seeding for UI tests. Lets a UI test fix the device and/or online version the check sees.

```swift
public enum NnVersionKitEnvironment {
    public static let deviceVersionKey: String
    public static let onlineVersionKey: String
    public static func seedValues(device: String? = nil, online: String? = nil) -> [String: String]
}
```

| Member | Description |
|--------|-------------|
| `deviceVersionKey` / `onlineVersionKey` | Namespaced launch-environment keys holding the seeded version strings. |
| `seedValues(device:online:)` | Returns **only** this package's keys for the provided versions — safe to merge into a launch environment populated by other seeders. Omit a version to leave its real loader in place. |

---

## Enabling seeding in the app

The bundle `checkingAppVersion` overload reads the seeded versions only when `enableUITestSeeding` is `true` (default `false`, so production never reads the environment):

```swift
ContentView()
    .checkingAppVersion(bundle: .main, updatePolicy: .majorOnly, enableUITestSeeding: true) {
        Text("Please update the app!")
    }
```

When enabled, a present `deviceVersionKey` / `onlineVersionKey` substitutes a `StaticVersionLoader` for that side; an absent key falls back to the real loader (bundle / App Store / custom).

---

## Seeding from the UI test

Set the values before launching. Because `seedValues` returns only its own keys, **merge** it rather than assigning `launchEnvironment`, so seeding composes with other tools (e.g. NnTestKit's `launchSeeded`):

```swift
app.launchEnvironment.merge(
    NnVersionKitEnvironment.seedValues(device: "1.0.0", online: "2.0.0")
) { _, new in new }
app.launch()
```

| Seed | Drives |
|------|--------|
| `device 1.0.0 / online 2.0.0` | forced update view (`updateView`) |
| `device 1.0.0 / online 1.5.0` under a tolerant policy | `.updateAvailable` via the `onStatus` callback |

---

## Best Practices

- **Merge, never assign `launchEnvironment`** — assigning clobbers keys other seeders set. `seedValues` is scoped to this package precisely so a merge is safe.
- **No NnTestKit dependency** — these helpers are plain strings; they sit alongside `launchSeeded`/`setSeedConfig` without coupling.
- **Keep `enableUITestSeeding` opt-in** — leave it `false` in production code paths; flip it on only where a build needs to honor seeded versions.
- **Prefer `StaticVersionLoader` directly** for unit tests or non-test known-version sources; reach for environment seeding only when the app under test is a separate process (XCUITest).
