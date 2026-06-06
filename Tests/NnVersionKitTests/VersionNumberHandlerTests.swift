//
//  VersionNumberHandlerTests.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/4/25.
//

import Testing
@testable import NnVersionKit

struct VersionNumberHandlerTests {
    @Test
    func `Parses valid version string`() throws {
        let version = try VersionNumberHandler.makeNumber(from: "1.2.3")
        
        #expect(version.majorNum == 1)
        #expect(version.minorNum == 2)
        #expect(version.patchNum == 3)
    }
    
    @Test
    func `Fills missing minor and patch numbers with zeros`() throws {
        let version = try VersionNumberHandler.makeNumber(from: "5")
        
        #expect(version.majorNum == 5)
        #expect(version.minorNum == 0)
        #expect(version.patchNum == 0)
    }
    
    @Test
    func `Throws error when version string contains non-integers`() {
        #expect(throws: VersionKitError.missingNumber) {
            try VersionNumberHandler.makeNumber(from: "1.two.3")
        }
    }
}


// MARK: - Update Comparison
extension VersionNumberHandlerTests {
    @Test(arguments: VersionNumberType.allCases)
    func `Requires update when online major version is higher regardless of selected type`(selectedVersionNumberType: VersionNumberType) {
        let device = VersionNumber(majorNum: 1, minorNum: 0, patchNum: 0)
        let online = VersionNumber(majorNum: 2, minorNum: 0, patchNum: 0)
        
        #expect(VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: selectedVersionNumberType))
    }

    @Test
    func `Detects minor version increase only at minor and patch levels`() {
        let device = VersionNumber(majorNum: 1, minorNum: 1, patchNum: 0)
        let online = VersionNumber(majorNum: 1, minorNum: 2, patchNum: 0)

        #expect(!VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: .major))
        #expect(VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: .minor))
        #expect(VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: .patch))
    }

    @Test
    func `Detects patch version increase only at patch level`() {
        let device = VersionNumber(majorNum: 2, minorNum: 2, patchNum: 1)
        let online = VersionNumber(majorNum: 2, minorNum: 2, patchNum: 3)

        #expect(!VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: .major))
        #expect(!VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: .minor))
        #expect(VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, selectedVersionNumberType: .patch))
    }

    @Test(arguments: VersionNumberType.allCases)
    func `Does not require update when versions are equal`(selectedVersionNumberType: VersionNumberType) {
        let version = VersionNumber(majorNum: 1, minorNum: 1, patchNum: 1)

        #expect(!VersionNumberHandler.versionUpdateIsRequired(deviceVersion: version, onlineVersion: version, selectedVersionNumberType: selectedVersionNumberType))
    }
}
