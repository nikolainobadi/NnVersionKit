//
//  VersionNumber.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

/// A value type representing a semantic version number (major.minor.patch).
public struct VersionNumber: Equatable, Sendable {
    /// The major version number.
    public let majorNum: Int

    /// The minor version number.
    public let minorNum: Int

    /// The patch version number.
    public let patchNum: Int

    /// Creates a new `VersionNumber` instance with the provided components.
    ///
    /// - Parameters:
    ///   - majorNum: Major version.
    ///   - minorNum: Minor version.
    ///   - patchNum: Patch version.
    public init(majorNum: Int, minorNum: Int, patchNum: Int) {
        self.majorNum = majorNum
        self.minorNum = minorNum
        self.patchNum = patchNum
    }
}


// MARK: - Helpers
public extension VersionNumber {
    /// A string representation of the version in `major.minor.patch` format. (example: 1.0.0)
    var stringFormat: String {
        return "\(majorNum).\(minorNum).\(patchNum)"
    }
}

