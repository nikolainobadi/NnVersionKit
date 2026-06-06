//
//  AppStoreVersionLoader.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import Foundation

/// A version loader that retrieves the latest app version from the App Store using the app’s bundle identifier.
public final class AppStoreVersionLoader {
    private let bundleId: String?
    private let debugEnabled: Bool
    private let service: NetworkService

    /// Creates a new instance of `AppStoreVersionLoader`.
    ///
    /// - Parameters:
    ///   - bundleId: The bundle identifier of the app.
    ///   - debugEnabled: When `true`, prints version loading details to the console. Nothing is printed when `false`.
    ///   - service: The network service used to fetch data from the App Store.
    init(bundleId: String?, debugEnabled: Bool = false, service: NetworkService) {
        self.service = service
        self.bundleId = bundleId
        self.debugEnabled = debugEnabled
    }
}


// MARK: - Init
public extension AppStoreVersionLoader {
    /// Creates a new instance of `AppStoreVersionLoader`.
    ///
    /// - Parameters:
    ///   - bundleId: The bundle identifier of the app.
    ///   - debugEnabled: When `true`, prints version loading details to the console. Nothing is printed when `false` (default).
    convenience init(bundleId: String?, debugEnabled: Bool = false) {
        self.init(bundleId: bundleId, debugEnabled: debugEnabled, service: URLSessionNetworkService())
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
            log("Missing or invalid bundle ID, cannot fetch App Store version")
            throw VersionKitError.invalidBundleId
        }

        log("Fetching App Store version from \(url.absoluteString)")
        let data = try await service.fetchData(from: url)
        log("Received \(data.count) bytes from App Store lookup")

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let versionString = results.first?["version"] as? String else {
            log("Could not parse version string from App Store response")
            throw VersionKitError.missingDeviceVersionString
        }

        log("App Store version string: \(versionString)")
        return try VersionNumberHandler.makeNumber(from: versionString, debugEnabled: debugEnabled)
    }
}


// MARK: - Private Methods
private extension AppStoreVersionLoader {
    /// Prints a message to the console when debug logging is enabled.
    ///
    /// - Parameter message: The message to print.
    func log(_ message: String) {
        VersionKitLogger.log(message, isEnabled: debugEnabled)
    }
}


// MARK: - Dependencies
internal protocol NetworkService: Sendable {
    func fetchData(from url: URL) async throws -> Data
}

internal final class URLSessionNetworkService: NetworkService {
    func fetchData(from url: URL) async throws -> Data {
        return try await URLSession.shared.data(from: url).0
    }
}
