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
    private let debugEnabled: Bool

    /// Creates a new instance using the provided bundle.
    ///
    /// - Parameters:
    ///   - bundle: The bundle to extract version information from.
    ///   - debugEnabled: When `true`, prints version loading details to the console. Nothing is printed when `false` (default).
    public init(bundle: Bundle, debugEnabled: Bool = false) {
        self.bundle = bundle
        self.debugEnabled = debugEnabled
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
            log("Missing '\(String.bundleVersionKey)' in bundle Info.plist")
            throw VersionKitError.missingDeviceVersionString
        }

        log("Device version string from bundle: \(versionString)")
        return try VersionNumberHandler.makeNumber(from: versionString, debugEnabled: debugEnabled)
    }
}


// MARK: - Private Methods
private extension DeviceBundleVersionLoader {
    /// Prints a message to the console when debug logging is enabled.
    ///
    /// - Parameter message: The message to print.
    func log(_ message: String) {
        VersionKitLogger.log(message, isEnabled: debugEnabled)
    }
}


// MARK: - Extension Dependencies
public extension String {
    /// The Info.plist key used to retrieve the app's version string.
    static var bundleVersionKey: String {
        return "CFBundleShortVersionString"
    }
}
