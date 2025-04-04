//
//  VersionNumberHandlerTests.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/4/25.
//

import Testing
@testable import NnVersionKit

struct VersionNumberHandlerTests {
    @Test("Parses valid version string")
    func parsesValidVersionString() throws {
        let version = try VersionNumberHandler.makeNumber(from: "1.2.3")
        
        #expect(version.majorNum == 1)
        #expect(version.minorNum == 2)
        #expect(version.patchNum == 3)
    }
    
    @Test("Parses version string with missing minor and patch")
    func fillsMissingMinorAndPatchWithZeros() throws {
        let version = try VersionNumberHandler.makeNumber(from: "5")
        
        #expect(version.majorNum == 5)
        #expect(version.minorNum == 0)
        #expect(version.patchNum == 0)
    }
    
    @Test("Throws error when version string contains non-integers")
    func throwsOnInvalidVersionString() {
        #expect(throws: VersionKitError.missingNumber) {
            try VersionNumberHandler.makeNumber(from: "1.two.3")
        }
    }

    @Test("Compares major version update", arguments: VersionNumberType.allCases)
    func detectsMajorUpdate(selectedVersionNumberType: VersionNumberType) {
        let device = VersionNumber(majorNum: 1, minorNum: 0, patchNum: 0)
        let online = VersionNumber(majorNum: 2, minorNum: 0, patchNum: 0)
        
        #expect(VersionNumberHandler.compareVersions(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: selectedVersionNumberType))
    }

    @Test("Compares minor version update")
    func detectsMinorUpdate() {
        let device = VersionNumber(majorNum: 1, minorNum: 1, patchNum: 0)
        let online = VersionNumber(majorNum: 1, minorNum: 2, patchNum: 0)

        #expect(!VersionNumberHandler.compareVersions(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: .major))
        #expect(VersionNumberHandler.compareVersions(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: .minor))
        #expect(VersionNumberHandler.compareVersions(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: .patch))
    }

    @Test("Compares patch version update")
    func detectsPatchUpdate() {
        let device = VersionNumber(majorNum: 2, minorNum: 2, patchNum: 1)
        let online = VersionNumber(majorNum: 2, minorNum: 2, patchNum: 3)

        #expect(!VersionNumberHandler.compareVersions(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: .major))
        #expect(!VersionNumberHandler.compareVersions(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: .minor))
        #expect(VersionNumberHandler.compareVersions(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: .patch))
    }

    @Test("Returns false when all version numbers are the same", arguments: VersionNumberType.allCases)
    func returnsFalseIfVersionsAreEqual(selectedVersionNumberType: VersionNumberType) {
        let version = VersionNumber(majorNum: 1, minorNum: 1, patchNum: 1)

        #expect(!VersionNumberHandler.compareVersions(deviceVersion: version, onlineVersion: version, selectedVersionNumberType: selectedVersionNumberType))
    }
}
