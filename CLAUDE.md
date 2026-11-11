# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NnVersionKit is a Swift Package that detects when an app update is available by comparing the
installed version against the App Store (or any custom source), and exposes a SwiftUI view modifier
that either swaps in an update prompt or reports the result to the client. iOS 17+, macOS 14+,
Swift 6.0, no external dependencies.

## Building and Testing

```bash
swift build
swift test
swift build -c release
swift package clean
```

Open in Xcode with `open .swiftpm/xcode/package.xcworkspace`.

## Architecture

Four layers, each in its own directory under `Sources/NnVersionKit/`:

**`Model/`** — the value types. `VersionNumber` is an `Equatable, Comparable, Sendable, Identifiable`
triple of major/minor/patch; `Comparable` makes `device < online` a holistic "is the device behind"
check, and `Identifiable` (`id` is `stringFormat`) lets a version drive `.sheet(item:)`.
`VersionUpdatePolicy` decides how far behind is too far, `VersionUpdateStatus` is the three-way
outcome, and `VersionKitError` is every error the package throws. `VersionNumberType` is internal —
it exists only as a parsing index and is deliberately not public.

**`Utilities/VersionNumberHandler`** — the comparison brain, a namespace enum of statics.
`makeNumber(from:)` parses; `versionUpdateIsRequired(...)` applies the policy; `versionStatus(...)`
wraps that into the three-way `VersionUpdateStatus`. Every loader delegates its parsing here, so
version-string semantics are defined in exactly one place.

**`Loaders/`** — `VersionLoader` is the single-method protocol everything is written against.
`DeviceBundleVersionLoader` reads `CFBundleShortVersionString`, `AppStoreVersionLoader` hits the
iTunes Lookup API, `StaticVersionLoader` returns a fixed value. `NnVersionKitEnvironment` is
launch-environment seeding for UI tests, and it is opt-in: the modifier only consults it when
`enableUITestSeeding` is `true`, so production never reads the environment.

**`ViewModifier/`** — `VersionCheckViewModel` runs the check in a `.task` (device load, then online
load, sequentially) and resolves a status. Two modifiers consume it: `VersionCheckViewModifier`
replaces content with `updateView` on `.updateRequired`, and `VersionStatusViewModifier` replaces
nothing and only reports through `onStatus`.

### Two presentation modes, one check

The four `checkingAppVersion` overloads are a 2×2: bundle-convenience vs. two-loader, crossed with
present-`updateView` vs. report-only. The report-only pair takes `onStatus` as a required trailing
closure and never touches the view hierarchy, so a client that wants to own the forced-update
presentation can. Adding a fifth entry point is almost never the right move — extend the 2×2 or the
policy instead.

### Failing open

A loader that throws invokes `onError` and leaves content visible. The update view is never shown on
error. Network failures from `AppStoreVersionLoader` propagate **unwrapped** rather than as a
`VersionKitError`.

## Code Standards

Files carry no header comment block.
Public API is marked `public` explicitly; private helpers are grouped under a
`// MARK: - Private Methods` `private extension`. Public declarations carry doc comments with
parameters and a `Throws:` clause where applicable.

## The NnVersionKit Skill

The published API reference skill lives in this repo, at `Skills/NnVersionKit/`. It used to live in
`~/NobadiScripts/NnSkills/MultiPlatform_Skills/` — that path is dead, do not look for it there.

It sits here so that **the API and its documentation change in the same PR.** Kept in separate repos
they drift: the skill goes on describing an API that has since been renamed, and nothing anywhere
reports it.

### The rule

**A PR that changes the public API must also touch `Skills/`.** There is no CI workflow enforcing
this rule. Review behavior changes as well as declarations: the floor arithmetic in
`VersionNumberHandler.versionUpdateIsRequired` decides exactly which devices get forced, and
`Skills/NnVersionKit/skills/NnVersionKit/VersionModelApi.md` documents that arithmetic down to the
worked example.

### `plugin.json` deliberately has no `version`

`Skills/NnVersionKit/.claude-plugin/plugin.json` intentionally carries **no `version` field.** The
marketplace installs this skill from a git source and keys its cache by commit sha, so a hand-typed
version number is a second thing to remember and the exact stale-number problem this arrangement
exists to remove. Do not reintroduce it. The pinned `ref` in the marketplace manifest is the real
version marker.

## Releasing

The skill is published through the **`nn-swift-skills`** marketplace
(`nikolainobadi/nn-swift-skills`), whose entry uses a `git-subdir` source pinned to a **release tag**
of this repo.

Because it is pinned, **doc changes ship on release, not on merge.** Merging a correction to
`Skills/` changes nothing for anyone reading the skill until the next tag. That surprises people —
it is the intended trade (docs always match a shipped version), not a bug.

**The marketplace `ref` bump is a manual cross-repo step.** Update the entry in
`nikolainobadi/nn-swift-skills` to the release tag; this repo has no workflow that opens that PR.
Until the marketplace update merges, consumers keep reading the previously pinned release's
documentation.

Tags in this repo are unprefixed (`2.0.0`, not `v2.0.0`); `v1.0.0` is a legacy exception.

