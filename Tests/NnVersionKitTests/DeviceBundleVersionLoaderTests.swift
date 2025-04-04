//
//  DeviceBundleVersionLoaderTests.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/4/25.
//

import Testing
import Foundation
@testable import NnVersionKit

struct DeviceBundleVersionLoaderTests {
    @Test("Parses version string from bundle correctly")
    func loadsVersionFromBundle() async throws {
        let bundle = TestBundle(info: [.bundleVersionKey: "1.2.3"])
        let sut = DeviceBundleVersionLoader(bundle: bundle)

        let version = try await sut.loadVersionNumber()

        #expect(version.majorNum == 1)
        #expect(version.minorNum == 2)
        #expect(version.patchNum == 3)
    }

    @Test("Throws if version string is missing")
    func throwsWhenVersionStringMissing() async {
        let bundle = TestBundle(info: [:])
        let sut = DeviceBundleVersionLoader(bundle: bundle)

        await #expect(throws: VersionKitError.missingDeviceVersionString) {
            try await sut.loadVersionNumber()
        }
    }

    @Test("Throws if version string is not a string")
    func throwsWhenVersionStringIsNotAString() async {
        let bundle = TestBundle(info: [.bundleVersionKey: 123])
        let sut = DeviceBundleVersionLoader(bundle: bundle)

        await #expect(throws: VersionKitError.missingDeviceVersionString) {
            try await sut.loadVersionNumber()
        }
    }
}


// MARK: - Helpers
private extension DeviceBundleVersionLoaderTests {
    final class TestBundle: Bundle, @unchecked Sendable {
        private let customInfo: [String: Any]?

        init(info: [String: Any]?) {
            self.customInfo = info
            super.init()
        }

        override var infoDictionary: [String: Any]? {
            return customInfo
        }
    }
}
