//
//  VersionNumberHandler.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import Foundation

/// Utility methods for creating and comparing semantic version numbers.
public enum VersionNumberHandler {
    /// Converts a version string (e.g., "1.2.3") into a `VersionNumber`.
    ///
    /// - Parameter versionString: The version string to convert.
    /// - Returns: A `VersionNumber` constructed from the string.
    /// - Throws: `VersionKitError.missingNumber` if any segment of the version string is not a valid number.
    public static func makeNumber(from versionString: String) throws -> VersionNumber {
        let noDecimals = versionString.components(separatedBy: ".")
        let array = noDecimals.compactMap { Int($0) }

        guard array.count == noDecimals.count else {
            throw VersionKitError.missingNumber
        }

        return makeVersionNumber(from: array)
    }

    /// Compares two version numbers using a selected comparison type.
    ///
    /// - Parameters:
    ///   - deviceVersion: The version currently on the device.
    ///   - onlineVersion: The version available online (e.g., App Store).
    ///   - selectedVersionNumberType: The level of version comparison (major, minor, or patch).
    /// - Returns: `true` if an update is required based on the selected comparison type.
    public static func compareVersions(deviceVersion: VersionNumber, onlineVersion: VersionNumber, selectedVersionNumberType: VersionNumberType) -> Bool {
        let majorUpdate = deviceVersion.majorNum < onlineVersion.majorNum
        let minorUpdate = deviceVersion.minorNum < onlineVersion.minorNum
        let patchUpdate = deviceVersion.patchNum < onlineVersion.patchNum

        switch selectedVersionNumberType {
        case .major:
            return majorUpdate
        case .minor:
            return majorUpdate || minorUpdate
        case .patch:
            return majorUpdate || minorUpdate || patchUpdate
        }
    }
}


// MARK: - Private Methods
private extension VersionNumberHandler {
    /// Creates a `VersionNumber` from an array of integers.
    ///
    /// - Parameter array: The array containing major, minor, and patch version components.
    /// - Returns: A constructed `VersionNumber`, defaulting to `0` for missing components.
    static func makeVersionNumber(from array: [Int]) -> VersionNumber {
        return .init(
            majorNum: getNumber(.major, in: array),
            minorNum: getNumber(.minor, in: array),
            patchNum: getNumber(.patch, in: array)
        )
    }

    /// Retrieves the integer value for a specific version component from an array.
    ///
    /// - Parameters:
    ///   - numtype: The version component type (major, minor, or patch).
    ///   - array: The array to read from.
    /// - Returns: The corresponding number, or 0 if the index is out of bounds.
    static func getNumber(_ numtype: VersionNumberType, in array: [Int]) -> Int {
        let index = numtype.rawValue
        
        return array.count > index ? array[index] : 0
    }
}
