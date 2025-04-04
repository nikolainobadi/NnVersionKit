//
//  DeviceBundleVersionLoader.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import Foundation

/// A version loader that retrieves the app version from the local bundle.
public final class DeviceBundleVersionLoader {
    private let bundle: Bundle

    /// Creates a new instance using the provided bundle.
    ///
    /// - Parameter bundle: The bundle to extract version information from.
    init(bundle: Bundle) {
        self.bundle = bundle
    }
}

// MARK: - DeviceVersionStore
extension DeviceBundleVersionLoader: VersionLoader {
    /// Loads the version number from the app's bundle Info.plist.
    ///
    /// - Returns: The version number parsed from the bundle.
    /// - Throws: `VersionKitError.missingDeviceVersionString` if the version string is missing or invalid.
    public func loadVersionNumber() async throws -> VersionNumber {
        guard let dict = bundle.infoDictionary,
              let versionString = dict[.bundleVersionKey] as? String else {
            throw VersionKitError.missingDeviceVersionString
        }

        return try VersionNumberHandler.makeNumber(from: versionString)
    }
}


// MARK: - Extension Dependencies
public extension String {
    /// The Info.plist key used to retrieve the app's version string.
    static var bundleVersionKey: String {
        return "CFBundleShortVersionString"
    }
}
