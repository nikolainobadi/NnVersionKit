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

File headers follow `// FileName.swift / NnVersionKit / Created by Nikolai Nobadi on [date]`.
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

**A PR that changes the public API must also touch `Skills/`.** `.github/workflows/skill-docs.yml`
enforces it: it counts added/removed `public`/`open`/`package` declaration lines under
`Sources/**/*.swift` and fails the PR if `Skills/` is untouched. Add the `skip-skill-check` label
when the PR genuinely changes no documented behavior — a rename, a reformat, a file move.

**The check has a real blind spot.** It only sees *declaration* lines. A behavior change inside a
public function body is invisible to it, and this package is unusually exposed to that: the floor
arithmetic in `VersionNumberHandler.versionUpdateIsRequired` decides exactly which devices get
forced, and `Skills/NnVersionKit/skills/NnVersionKit/VersionModelApi.md` documents that arithmetic
down to the worked example. Change the rule and the check scores `api: 0` while the skill goes
wrong. Treat it as a floor, not a guarantee.

### `plugin.json` deliberately has no `version`

`Skills/NnVersionKit/.claude-plugin/plugin.json` intentionally carries **no `version` field.** The
marketplace installs this skill from a git source and keys its cache by commit sha, so a hand-typed
version number is a second thing to remember and the exact stale-number problem this arrangement
exists to remove. Do not reintroduce it. The pinned `ref` in the marketplace manifest is the real
version marker, and that one is bumped automatically.

## Releasing

The skill is published through the **`nn-swift-skills`** marketplace
(`nikolainobadi/nn-swift-skills`), whose entry uses a `git-subdir` source pinned to a **release tag**
of this repo.

Because it is pinned, **doc changes ship on release, not on merge.** Merging a correction to
`Skills/` changes nothing for anyone reading the skill until the next tag. That surprises people —
it is the intended trade (docs always match a shipped version), not a bug.

`.github/workflows/skill-ref-bump.yml` handles the bump: on any tag push it rewrites the entry's
`ref` in the marketplace manifest and opens a PR there. It can also be run manually with
`gh workflow run skill-ref-bump.yml -f tag=<tag>`.

**If that automation is ever removed, the bump becomes a manual cross-repo step**, and the failure
mode is silent: the marketplace keeps serving the previously pinned release's documentation forever.
Nothing errors and nothing warns — consumers simply read old docs.

Tags in this repo are unprefixed (`2.0.0`, not `v2.0.0`); `v1.0.0` is a legacy exception.

### The `MARKETPLACE_TOKEN` secret

The bump workflow authenticates with the repo secret `MARKETPLACE_TOKEN` — a **fine-grained PAT
named `nn-swift-skills-ref-bump`**, granting `contents:write` and `pull-requests:write` on
`nikolainobadi/nn-swift-skills` and nothing else.

- It is **shared across every package repo** publishing to `nn-swift-skills` (SwiftPickerKit,
  NnArgumentParser, NnTestKit, NnShellKit, NnFileKit, NnSwiftUIKit, this one). The grant is identical
  in each, so a per-repo token would buy no isolation and cost another expiry to track.
- **Expiry:** _record the expiry date here when the token is next rotated._ When it lapses, the bump
  fails in **every** repo holding it — so a failed run reads as "rotate the shared token", not "this
  repo's workflow is broken." Rotation means re-running `set-marketplace-token.sh` against every
  package repo.
- GitHub secrets are **write-only.** The value cannot be read back from a repo that already has it;
  adding a new repo needs the saved token file.
