//
//  VersionNumberType.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

/// Identifies a semantic version component by its position when parsing a version string.
///
/// The raw value doubles as the component's index in a parsed `[major, minor, patch]` array.
enum VersionNumberType: Int {
    /// The major version component (index 0).
    case major

    /// The minor version component (index 1).
    case minor

    /// The patch version component (index 2).
    case patch
}
