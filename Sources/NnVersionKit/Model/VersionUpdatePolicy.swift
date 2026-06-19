//
//  VersionUpdatePolicy.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 6/19/25.
//

/// Determines how far behind the latest version a device may fall before an update is forced.
///
/// A new major version always forces an update under every policy, because a major bump is a
/// breaking change. On top of that baseline, a client may optionally tolerate a window of recent
/// releases at a single sub-level — minor *or* patch.
public enum VersionUpdatePolicy: Sendable, Equatable {
    /// Only a new major version forces an update.
    ///
    /// Any number of minor or patch releases behind the latest is allowed. This is the default.
    case majorOnly

    /// Forces an update on a new major version, or when the device is more than
    /// `allowedPreviousVersions` minor releases behind the latest. Patch differences are ignored.
    ///
    /// - Parameter allowedPreviousVersions: How many minor releases behind the latest are tolerated.
    ///   `0` requires the latest minor. Negative values are treated as `0`.
    case minor(allowedPreviousVersions: Int)

    /// Forces an update on a new major version, on any new minor version, or when the device is more
    /// than `allowedPreviousVersions` patch releases behind the latest within the same minor.
    ///
    /// - Parameter allowedPreviousVersions: How many patch releases behind the latest are tolerated.
    ///   `0` requires the latest patch. Negative values are treated as `0`.
    case patch(allowedPreviousVersions: Int)
}
