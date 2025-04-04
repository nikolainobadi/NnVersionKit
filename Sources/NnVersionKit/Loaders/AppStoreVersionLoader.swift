//
//  AppStoreVersionLoader.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import Foundation

/// A version loader that retrieves the latest app version from the App Store using the app’s bundle identifier.
public final class AppStoreVersionLoader {
    /// The bundle identifier used to query the App Store.
    private let bundleId: String?

    /// Creates a new instance of `AppStoreVersionLoader`.
    ///
    /// - Parameter bundleId: The bundle identifier of the app.
    init(bundleId: String?) {
        self.bundleId = bundleId
    }
}

// MARK: - VersionLoader
extension AppStoreVersionLoader: VersionLoader {
    /// Loads the version number from the App Store using the iTunes Lookup API.
    ///
    /// - Returns: The version number fetched from the App Store.
    /// - Throws: `VersionKitError.invalidBundleId` if the bundle ID is missing or invalid.
    ///           `VersionKitError.missingDeviceVersionString` if the version could not be parsed from the API response.
    public func loadVersionNumber() async throws -> VersionNumber {
        guard let bundleId = bundleId,
              let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else {
            throw VersionKitError.invalidBundleId
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let versionString = results.first?["version"] as? String else {
            throw VersionKitError.missingDeviceVersionString
        }

        return try VersionNumberHandler.makeNumber(from: versionString)
    }
}
