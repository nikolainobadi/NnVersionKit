//
//  VersionLoader.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/4/25.
//

public protocol VersionLoader: Sendable {
    func loadVersionNumber() async throws -> VersionNumber
}
