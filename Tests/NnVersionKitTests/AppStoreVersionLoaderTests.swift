//
//  AppStoreVersionLoaderTests.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/4/25.
//

import Testing
import Foundation
@testable import NnVersionKit

struct AppStoreVersionLoaderTests {
    @Test
    func `Parses version string from App Store response`() async throws {
        let data = try makeJSONData()
        let sut = makeSUT(bundleId: "com.example.app", result: .success(data))
        let version = try await sut.loadVersionNumber()

        #expect(version.majorNum == 2)
        #expect(version.minorNum == 3)
        #expect(version.patchNum == 4)
    }

    @Test
    func `Throws if bundle ID is nil`() async {
        let sut = makeSUT(result: .success(Data()))

        await #expect(throws: VersionKitError.invalidBundleId) {
            try await sut.loadVersionNumber()
        }
    }

    @Test
    func `Throws if version cannot be parsed from API response`() async throws {
        let badData = try makeJSONData(content: ["no_version": "oops"])
        let sut = makeSUT(bundleId: "com.example.app", result: .success(badData))

        await #expect(throws: VersionKitError.missingDeviceVersionString) {
            try await sut.loadVersionNumber()
        }
    }

    @Test
    func `Throws if network call fails`() async {
        let sut = makeSUT(bundleId: "com.example.app", result: .failure(TestError.network))

        await #expect(throws: TestError.network) {
            try await sut.loadVersionNumber()
        }
    }
}


// MARK: - Helpers
private extension AppStoreVersionLoaderTests {
    typealias NetworkResult = Result<Data, Error>
    enum TestError: Error {
        case network
    }

    func makeJSONData(content: [String: String] = ["version": "2.3.4"]) throws -> Data {
        let json = [
            "results": [
                content
            ]
        ]

        return try JSONSerialization.data(withJSONObject: json)
    }

    struct MockNetworkService: NetworkService, @unchecked Sendable {
        let result: NetworkResult

        func fetchData(from url: URL) async throws -> Data {
            switch result {
            case .success(let data): return data
            case .failure(let error): throw error
            }
        }
    }
}


// MARK: - SUT
private extension AppStoreVersionLoaderTests {
    func makeSUT(bundleId: String? = nil, result: NetworkResult) -> AppStoreVersionLoader {
        let service = MockNetworkService(result: result)

        return .init(bundleId: bundleId, service: service)
    }
}
