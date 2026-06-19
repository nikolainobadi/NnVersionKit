//
//  StaticVersionLoader.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 6/19/25.
//

/// A `VersionLoader` that returns a fixed version number.
///
/// Useful for driving the update check deterministically in UI tests, and for any source where the
/// version is already known (e.g. a value pulled from remote config before the check runs).
public struct StaticVersionLoader: VersionLoader {
    private let version: VersionNumber

    /// Creates a loader that always returns the given version.
    public init(version: VersionNumber) {
        self.version = version
    }

    /// Creates a loader from a version string (e.g. `"1.2.3"`), parsed with `VersionNumberHandler`.
    ///
    /// - Throws: `VersionKitError.missingNumber` if the string contains a non-numeric segment.
    public init(versionString: String, debugEnabled: Bool = false) throws {
        self.version = try VersionNumberHandler.makeNumber(from: versionString, debugEnabled: debugEnabled)
    }

    public func loadVersionNumber() async throws -> VersionNumber {
        return version
    }
}
