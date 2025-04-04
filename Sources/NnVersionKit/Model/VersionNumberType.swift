//
//  VersionNumberType.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

/// Specifies the type of version component to compare when checking for updates.
public enum VersionNumberType: Int, CaseIterable, Sendable {
    /// Compare only the major version.
    case major

    /// Compare major and minor versions.
    case minor

    /// Compare major, minor, and patch versions.
    case patch
}
