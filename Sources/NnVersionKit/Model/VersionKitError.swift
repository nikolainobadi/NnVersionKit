//
//  VersionKitError.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

public enum VersionKitError: Error {
    case missingNumber
    case invalidBundleId
    case missingDeviceVersionString
    case unableToFetchVersionFromAppStore
}
