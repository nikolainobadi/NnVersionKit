//
//  AppStoreVersionLoader.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import Foundation

public final class AppStoreVersionLoader {
    private let bundleId: String?
    
    init(bundleId: String?) {
        self.bundleId = bundleId
    }
}

// MARK: - VersionLoader
extension AppStoreVersionLoader: VersionLoader {
    public func loadVersionNumber() async throws -> VersionNumber {
        guard let bundleId = bundleId, let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else {
            throw VersionKitError.invalidBundleId
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            let versionString = results.first?["version"] as? String
        else {
            throw VersionKitError.missingDeviceVersionString
        }
        
        return try VersionNumberHandler.makeNumber(from: versionString)
    }
}
