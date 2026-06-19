//
//  NnVersionKitEnvironmentTests.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 6/19/25.
//

import Testing
@testable import NnVersionKit

struct NnVersionKitEnvironmentTests {
    @Test
    func `Seed values include only the keys that were provided`() {
        let values = NnVersionKitEnvironment.seedValues(device: "1.0.0")

        #expect(values == [NnVersionKitEnvironment.deviceVersionKey: "1.0.0"])
    }

    @Test
    func `Seed values are empty when nothing is provided`() {
        #expect(NnVersionKitEnvironment.seedValues().isEmpty)
    }

    @Test
    func `Builds a seeded device loader from the environment`() async throws {
        let environment = [NnVersionKitEnvironment.deviceVersionKey: "1.2.3"]

        let loader = try #require(NnVersionKitEnvironment.seededDeviceLoader(in: environment))
        let loaded = try await loader.loadVersionNumber()

        #expect(loaded == VersionNumber(majorNum: 1, minorNum: 2, patchNum: 3))
    }

    @Test
    func `Returns no online loader when the key is absent`() {
        #expect(NnVersionKitEnvironment.seededOnlineLoader(in: [:]) == nil)
    }
}
