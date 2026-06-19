//
//  StaticVersionLoaderTests.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 6/19/25.
//

import Testing
@testable import NnVersionKit

struct StaticVersionLoaderTests {
    @Test
    func `Returns the provided version`() async throws {
        let version = VersionNumber(majorNum: 3, minorNum: 1, patchNum: 4)
        let sut = StaticVersionLoader(version: version)

        let loaded = try await sut.loadVersionNumber()

        #expect(loaded == version)
    }

    @Test
    func `Parses a version string into a version number`() async throws {
        let sut = try StaticVersionLoader(versionString: "2.5.1")

        let loaded = try await sut.loadVersionNumber()

        #expect(loaded == VersionNumber(majorNum: 2, minorNum: 5, patchNum: 1))
    }

    @Test
    func `Throws when the version string is invalid`() {
        #expect(throws: VersionKitError.missingNumber) {
            try StaticVersionLoader(versionString: "1.x.3")
        }
    }
}
