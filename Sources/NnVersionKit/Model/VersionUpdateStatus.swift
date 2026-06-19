//
//  VersionUpdateStatus.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 6/19/25.
//

/// The outcome of comparing the device version against the latest online version under a `VersionUpdatePolicy`.
public enum VersionUpdateStatus: Sendable, Equatable {
    /// The device is on the latest version or ahead of it. No update is available.
    case upToDate

    /// The device is behind the latest version, but the policy does not force an update.
    /// Use this to surface a non-blocking "update available" prompt.
    case updateAvailable

    /// The policy requires an update — the device is too far behind (or a full major behind).
    case updateRequired
}

/// Handler invoked after a version check with the resolved status and the online version.
///
/// Used by the `onStatus` parameter on the `checkingAppVersion` view modifiers.
public typealias VersionStatusHandler = (VersionUpdateStatus, VersionNumber) -> Void
