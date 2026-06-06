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
    @Test
    func `Parses version string from bundle correctly`() async throws {
        let sut = makeSUT(info: [.bundleVersionKey: "1.2.3"])

        let version = try await sut.loadVersionNumber()

        #expect(version.majorNum == 1)
        #expect(version.minorNum == 2)
        #expect(version.patchNum == 3)
    }

    @Test
    func `Throws if version string is missing`() async {
        let sut = makeSUT()

        await #expect(throws: VersionKitError.missingDeviceVersionString) {
            try await sut.loadVersionNumber()
        }
    }

    @Test
    func `Throws if version string is not a string`() async {
        let sut = makeSUT(info: [.bundleVersionKey: 123])

        await #expect(throws: VersionKitError.missingDeviceVersionString) {
            try await sut.loadVersionNumber()
        }
    }
}


// MARK: - Helpers
private extension DeviceBundleVersionLoaderTests {
    final class MockBundle: Bundle, @unchecked Sendable {
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


// MARK: - SUT
private extension DeviceBundleVersionLoaderTests {
    func makeSUT(info: [String: Any] = [:]) -> DeviceBundleVersionLoader {
        return DeviceBundleVersionLoader(bundle: MockBundle(info: info))
    }
}
