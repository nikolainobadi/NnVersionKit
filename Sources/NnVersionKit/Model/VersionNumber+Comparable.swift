//
//  VersionNumber+Comparable.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 6/19/25.
//

extension VersionNumber: Comparable {
    /// Orders versions lexicographically by major, then minor, then patch.
    public static func < (lhs: VersionNumber, rhs: VersionNumber) -> Bool {
        (lhs.majorNum, lhs.minorNum, lhs.patchNum) < (rhs.majorNum, rhs.minorNum, rhs.patchNum)
    }
}

extension VersionNumber: Identifiable {
    /// The `major.minor.patch` string, so a version can drive `.sheet(item:)` / `.fullScreenCover(item:)`
    /// when a client presents the update UI itself.
    public var id: String {
        stringFormat
    }
}
