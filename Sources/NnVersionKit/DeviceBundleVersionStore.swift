//
//  DeviceBundleVersionStore.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import Foundation

public final class DeviceBundleVersionStore {
    private let bundle: Bundle
    private let versionStringId = "CFBundleShortVersionString"
    
    init(bundle: Bundle) {
        self.bundle = bundle
    }
}


// MARK: - DeviceVersionStore
extension DeviceBundleVersionStore: VersionLoader {
    public func loadVersionNumber() async throws -> VersionNumber {
        guard let dict = bundle.infoDictionary, let versionString = dict[versionStringId] as? String else {
            throw VersionKitError.missingDeviceVersionString
        }
        
        return try VersionNumberMapper.map(versionString)
    }
}
