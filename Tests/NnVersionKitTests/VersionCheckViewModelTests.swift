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
    @Test("Triggers update when online version is higher")
    func triggersUpdateIfNewerVersionExists() async throws {
        let device: LoaderResult = .success(.init(majorNum: 1, minorNum: 0, patchNum: 0))
        let online: LoaderResult = .success(.init(majorNum: 2, minorNum: 0, patchNum: 0))
        let sut = makeSUT(deviceResult: device, onlineResult: online, type: .major, result: online)

        await sut.checkVersions()

        #expect(sut.versionUpdateRequired)
    }

    @Test("Does not trigger update when versions are equal")
    func doesNotTriggerUpdateIfVersionsAreSame() async throws {
        let version = VersionNumber(majorNum: 1, minorNum: 2, patchNum: 3)
        let result: LoaderResult = .success(version)
        let sut = makeSUT(deviceResult: result, onlineResult: result, type: .patch, result: result)

        await sut.checkVersions()

        #expect(!sut.versionUpdateRequired)
    }

    @Test("Does not trigger update when lower level changes aren't required")
    func ignoresPatchUpdateIfMajorIsRequired() async throws {
        let device: LoaderResult = .success(.init(majorNum: 1, minorNum: 0, patchNum: 0))
        let online: LoaderResult = .success(.init(majorNum: 1, minorNum: 0, patchNum: 5))
        let sut = makeSUT(deviceResult: device, onlineResult: online, type: .major, result: online)

        await sut.checkVersions()

        #expect(!sut.versionUpdateRequired)
    }

    @Test("Calls error handler if version loading fails")
    func callsOnErrorWhenLoaderFails() async throws {
        var receivedError: Error?
        let error = TestError.versionLoader
        let device: LoaderResult = .failure(error)
        let online: LoaderResult = .success(.init(majorNum: 1, minorNum: 0, patchNum: 0))
        let sut = makeSUT(deviceResult: device, onlineResult: online, type: .major, result: device) {
            receivedError = $0
        }

        await sut.checkVersions()

        let thrown = try #require(receivedError)
        #expect(thrown as? TestError == .versionLoader)
        #expect(!sut.versionUpdateRequired)
    }
}



// MARK: - Helpers
private extension VersionCheckViewModelTests {
    func makeSUT(deviceResult: LoaderResult, onlineResult: LoaderResult, type: VersionNumberType, result: LoaderResult, onError: ((Error) -> Void)? = nil) -> VersionCheckViewModel {
        return .init(
            deviceVersionLoader: StubLoader(result: deviceResult),
            onlineVersionLoader: StubLoader(result: onlineResult),
            selectedVersionNumberType: type,
            onError: onError
        )
    }
}


// MARK: - Helpers
private extension VersionCheckViewModelTests {
    typealias LoaderResult = Result<VersionNumber, Error>
    enum TestError: Error, Equatable {
        case versionLoader
    }
    
    final class StubLoader: VersionLoader {
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
