//
//  NnVersionKitEnvironment.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 6/19/25.
//

import Foundation

/// Launch-environment seeding for UI tests.
///
/// Lets a UI test fix the device and/or online version the check sees, so the update UI (forced and
/// the soft "update available" state) can be driven deterministically.
///
/// The keys are namespaced to NnVersionKit and the helpers only ever set their own keys, so seeding
/// composes with other tools that mutate `launchEnvironment` (e.g. NnTestKit's `launchSeeded`). Merge
/// `seedValues(...)` into `launchEnvironment` rather than assigning it, so other seeded keys survive.
public enum NnVersionKitEnvironment {
    /// Environment key holding the seeded device version string.
    public static let deviceVersionKey = "NnVersionKit.uiTest.deviceVersion"

    /// Environment key holding the seeded online version string.
    public static let onlineVersionKey = "NnVersionKit.uiTest.onlineVersion"

    /// Builds the NnVersionKit-only environment entries for the given versions.
    ///
    /// Returns only this package's keys, so the result is safe to **merge** into a launch
    /// environment that other seeders have already populated:
    ///
    /// ```swift
    /// app.launchEnvironment.merge(NnVersionKitEnvironment.seedValues(device: "1.0.0", online: "2.0.0")) { _, new in new }
    /// ```
    ///
    /// - Parameters:
    ///   - device: The device version string to seed, or `nil` to leave the real device loader in place.
    ///   - online: The online version string to seed, or `nil` to leave the real online loader in place.
    public static func seedValues(device: String? = nil, online: String? = nil) -> [String: String] {
        var values: [String: String] = [:]

        if let device {
            values[deviceVersionKey] = device
        }

        if let online {
            values[onlineVersionKey] = online
        }

        return values
    }

    /// Returns a `StaticVersionLoader` for the seeded device version, or `nil` when the key is absent.
    static func seededDeviceLoader(in environment: [String: String] = ProcessInfo.processInfo.environment) -> (any VersionLoader)? {
        return seededLoader(forKey: deviceVersionKey, in: environment)
    }

    /// Returns a `StaticVersionLoader` for the seeded online version, or `nil` when the key is absent.
    static func seededOnlineLoader(in environment: [String: String] = ProcessInfo.processInfo.environment) -> (any VersionLoader)? {
        return seededLoader(forKey: onlineVersionKey, in: environment)
    }
}


// MARK: - Private Methods
private extension NnVersionKitEnvironment {
    static func seededLoader(forKey key: String, in environment: [String: String]) -> (any VersionLoader)? {
        guard let versionString = environment[key] else {
            return nil
        }

        return try? StaticVersionLoader(versionString: versionString)
    }
}
