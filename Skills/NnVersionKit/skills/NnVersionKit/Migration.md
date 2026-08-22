# Migrating to 2.0.0

NnVersionKit 2.0.0 replaces the `VersionNumberType` comparison level with `VersionUpdatePolicy`. A new major version always forces an update under every policy; the `.minor` and `.patch` cases let a device fall a configurable number of releases behind the latest before an update is forced.

## API changes at a glance

| 1.x | 2.0.0 |
|-----|-------|
| `versionNumberUpdateType: VersionNumberType = .major` (on `checkingAppVersion`) | `updatePolicy: VersionUpdatePolicy = .majorOnly` |
| `versionUpdateIsRequired(..., selectedVersionNumberType:)` | `versionUpdateIsRequired(..., policy:)` |
| `VersionNumberType` (public enum) | Removed from the public API |

## Mapping old levels to policies

| 1.x level | 2.0.0 policy | Behavior |
|-----------|--------------|----------|
| `.major` | `.majorOnly` | Identical: force only on a new major. |
| `.minor` | `.minor(allowedPreviousVersions: 0)` | Force on a new major or any new minor (device must be on the latest minor). |
| `.patch` | `.patch(allowedPreviousVersions: 0)` | Force on a new major, new minor, or any new patch (device must be on the latest patch). |

`allowedPreviousVersions: 0` reproduces the strict 1.x behavior. Raise it to tolerate a window of recent releases, e.g. `.minor(allowedPreviousVersions: 4)` accepts the four most recent minors.

## Before and after

View modifier:

```swift
// 1.x
.checkingAppVersion(bundle: .main, versionNumberUpdateType: .minor) {
    Text("Please update the app!")
}

// 2.0.0
.checkingAppVersion(bundle: .main, updatePolicy: .minor(allowedPreviousVersions: 0)) {
    Text("Please update the app!")
}
```

Manual comparison:

```swift
// 1.x
let updateRequired = VersionNumberHandler.versionUpdateIsRequired(
    deviceVersion: device,
    onlineVersion: online,
    selectedVersionNumberType: .patch
)

// 2.0.0
let updateRequired = VersionNumberHandler.versionUpdateIsRequired(
    deviceVersion: device,
    onlineVersion: online,
    policy: .patch(allowedPreviousVersions: 0)
)
```

## Behavior notes

- **The default is unchanged.** Callers that omitted `versionNumberUpdateType` defaulted to `.major`; in 2.0.0 they default to `.majorOnly`, which forces on a new major exactly as before. No code change is needed for the default path.
- **`.minor(0)` / `.patch(0)` are strictly safer than the old levels.** They match the 1.x behavior for same-major comparisons and also fix an edge case: when a device reported a higher major than the online source, 1.x could force an update from a lower minor or patch number. 2.0.0 never forces an update on a device that is ahead.
- **`VersionNumberType` is gone from the public API.** It remains internally for version-string parsing only. Replace any direct `.major` / `.minor` / `.patch` references with the matching `VersionUpdatePolicy` case.
