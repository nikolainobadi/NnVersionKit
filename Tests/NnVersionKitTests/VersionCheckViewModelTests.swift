//
//  VersionCheckViewModelTests.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/4/25.
//

import Testing
@testable import NnVersionKit

@MainActor
struct VersionCheckViewModelTests {
    @Test
    func `Triggers update when online version is higher`() async throws {
        let device: LoaderResult = .success(.init(majorNum: 1, minorNum: 0, patchNum: 0))
        let online: LoaderResult = .success(.init(majorNum: 2, minorNum: 0, patchNum: 0))
        let sut = makeSUT(deviceResult: device, onlineResult: online, type: .major)

        await sut.checkVersions()

        #expect(sut.versionUpdateRequired)
    }

    @Test
    func `Does not trigger update when versions are equal`() async throws {
        let version = VersionNumber(majorNum: 1, minorNum: 2, patchNum: 3)
        let result: LoaderResult = .success(version)
        let sut = makeSUT(deviceResult: result, onlineResult: result, type: .patch)

        await sut.checkVersions()

        #expect(!sut.versionUpdateRequired)
    }

    @Test
    func `Does not trigger update when lower level changes aren't required`() async throws {
        let device: LoaderResult = .success(.init(majorNum: 1, minorNum: 0, patchNum: 0))
        let online: LoaderResult = .success(.init(majorNum: 1, minorNum: 0, patchNum: 5))
        let sut = makeSUT(deviceResult: device, onlineResult: online, type: .major)

        await sut.checkVersions()

        #expect(!sut.versionUpdateRequired)
    }

    @Test
    func `Calls error handler if version loading fails`() async throws {
        var receivedError: Error?
        let error = TestError.versionLoader
        let device: LoaderResult = .failure(error)
        let online: LoaderResult = .success(.init(majorNum: 1, minorNum: 0, patchNum: 0))
        let sut = makeSUT(deviceResult: device, onlineResult: online, type: .major) {
            receivedError = $0
        }

        await sut.checkVersions()

        let thrown = try #require(receivedError as? TestError)
        #expect(thrown == error)
    }

    @Test
    func `Does not trigger update when version loading fails`() async {
        let device: LoaderResult = .failure(TestError.versionLoader)
        let online: LoaderResult = .success(.init(majorNum: 1, minorNum: 0, patchNum: 0))
        let sut = makeSUT(deviceResult: device, onlineResult: online, type: .major)

        await sut.checkVersions()

        #expect(!sut.versionUpdateRequired)
    }
}



// MARK: - Helpers
private extension VersionCheckViewModelTests {
    typealias LoaderResult = Result<VersionNumber, Error>
    enum TestError: Error, Equatable {
        case versionLoader
    }

    final class MockVersionLoader: VersionLoader {
        private let result: LoaderResult

        init(result: LoaderResult) {
            self.result = result
        }

        func loadVersionNumber() async throws -> VersionNumber {
            switch result {
            case .success(let version):
                return version
            case .failure(let error):
                throw error
            }
        }
    }
}


// MARK: - SUT
private extension VersionCheckViewModelTests {
    func makeSUT(deviceResult: LoaderResult, onlineResult: LoaderResult, type: VersionNumberType, onError: ((Error) -> Void)? = nil) -> VersionCheckViewModel {
        return .init(
            deviceVersionLoader: MockVersionLoader(result: deviceResult),
            onlineVersionLoader: MockVersionLoader(result: onlineResult),
            selectedVersionNumberType: type,
            onError: onError
        )
    }
}
