//
//  VersionLoader.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/4/25.
//

/// A protocol defining a loader that asynchronously retrieves a `VersionNumber`.
public protocol VersionLoader: Sendable {
    /// Asynchronously loads a version number.
    ///
    /// - Returns: A `VersionNumber` representing the loaded version.
    /// - Throws: An error if the version could not be retrieved or parsed.
    func loadVersionNumber() async throws -> VersionNumber
}
