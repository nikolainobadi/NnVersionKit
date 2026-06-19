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


// MARK: - Major-Only Policy
extension VersionNumberHandlerTests {
    @Test
    func `Forces update under major-only policy when online major is higher`() {
        let device = VersionNumber(majorNum: 1, minorNum: 9, patchNum: 9)
        let online = VersionNumber(majorNum: 2, minorNum: 0, patchNum: 0)

        #expect(VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: .majorOnly))
    }

    @Test
    func `Ignores minor and patch differences under major-only policy`() {
        let device = VersionNumber(majorNum: 1, minorNum: 0, patchNum: 0)
        let online = VersionNumber(majorNum: 1, minorNum: 9, patchNum: 9)

        #expect(!VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: .majorOnly))
    }
}


// MARK: - Minor Window Policy
extension VersionNumberHandlerTests {
    @Test
    func `Forces update when device falls below the minor window`() {
        let device = VersionNumber(majorNum: 4, minorNum: 30, patchNum: 0)
        let online = VersionNumber(majorNum: 4, minorNum: 35, patchNum: 0)

        #expect(VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: .minor(allowedPreviousVersions: 4)))
    }

    @Test
    func `Allows device sitting exactly at the minor window floor`() {
        let device = VersionNumber(majorNum: 4, minorNum: 31, patchNum: 0)
        let online = VersionNumber(majorNum: 4, minorNum: 35, patchNum: 0)

        #expect(!VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: .minor(allowedPreviousVersions: 4)))
    }

    @Test
    func `Ignores patch differences within an accepted minor`() {
        let device = VersionNumber(majorNum: 4, minorNum: 31, patchNum: 9)
        let online = VersionNumber(majorNum: 4, minorNum: 35, patchNum: 0)

        #expect(!VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: .minor(allowedPreviousVersions: 4)))
    }

    @Test
    func `Requires the latest minor when no previous minors are allowed`() {
        let device = VersionNumber(majorNum: 1, minorNum: 1, patchNum: 0)
        let online = VersionNumber(majorNum: 1, minorNum: 2, patchNum: 0)

        #expect(VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: .minor(allowedPreviousVersions: 0)))
    }

    @Test
    func `Never forces update when the minor window exceeds available history`() {
        let device = VersionNumber(majorNum: 1, minorNum: 0, patchNum: 0)
        let online = VersionNumber(majorNum: 1, minorNum: 2, patchNum: 0)

        #expect(!VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: .minor(allowedPreviousVersions: 10)))
    }

    @Test
    func `Treats a negative minor window as requiring the latest minor`() {
        let device = VersionNumber(majorNum: 1, minorNum: 1, patchNum: 0)
        let online = VersionNumber(majorNum: 1, minorNum: 2, patchNum: 0)

        #expect(VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: .minor(allowedPreviousVersions: -5)))
    }
}


// MARK: - Patch Window Policy
extension VersionNumberHandlerTests {
    @Test
    func `Forces update when device falls below the patch window`() {
        let device = VersionNumber(majorNum: 1, minorNum: 4, patchNum: 7)
        let online = VersionNumber(majorNum: 1, minorNum: 4, patchNum: 10)

        #expect(VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: .patch(allowedPreviousVersions: 2)))
    }

    @Test
    func `Allows device sitting exactly at the patch window floor`() {
        let device = VersionNumber(majorNum: 1, minorNum: 4, patchNum: 8)
        let online = VersionNumber(majorNum: 1, minorNum: 4, patchNum: 10)

        #expect(!VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: .patch(allowedPreviousVersions: 2)))
    }

    @Test
    func `Forces update on any new minor under a patch policy`() {
        let device = VersionNumber(majorNum: 1, minorNum: 3, patchNum: 99)
        let online = VersionNumber(majorNum: 1, minorNum: 4, patchNum: 0)

        #expect(VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: .patch(allowedPreviousVersions: 2)))
    }

    @Test
    func `Requires the latest patch when no previous patches are allowed`() {
        let device = VersionNumber(majorNum: 1, minorNum: 0, patchNum: 0)
        let online = VersionNumber(majorNum: 1, minorNum: 0, patchNum: 1)

        #expect(VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: .patch(allowedPreviousVersions: 0)))
    }
}


// MARK: - Policy Baselines
extension VersionNumberHandlerTests {
    @Test(arguments: [VersionUpdatePolicy.majorOnly, .minor(allowedPreviousVersions: 4), .patch(allowedPreviousVersions: 4)])
    func `Forces update when a full major behind regardless of policy`(policy: VersionUpdatePolicy) {
        let device = VersionNumber(majorNum: 1, minorNum: 5, patchNum: 5)
        let online = VersionNumber(majorNum: 2, minorNum: 0, patchNum: 0)

        #expect(VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: policy))
    }

    @Test(arguments: [VersionUpdatePolicy.majorOnly, .minor(allowedPreviousVersions: 4), .patch(allowedPreviousVersions: 4)])
    func `Never forces update when the device is ahead of online`(policy: VersionUpdatePolicy) {
        let device = VersionNumber(majorNum: 4, minorNum: 36, patchNum: 0)
        let online = VersionNumber(majorNum: 4, minorNum: 35, patchNum: 0)

        #expect(!VersionNumberHandler.versionUpdateIsRequired(deviceVersion: device, onlineVersion: online, policy: policy))
    }

    @Test(arguments: [VersionUpdatePolicy.majorOnly, .minor(allowedPreviousVersions: 4), .patch(allowedPreviousVersions: 4)])
    func `Does not force update when versions are equal regardless of policy`(policy: VersionUpdatePolicy) {
        let version = VersionNumber(majorNum: 1, minorNum: 1, patchNum: 1)

        #expect(!VersionNumberHandler.versionUpdateIsRequired(deviceVersion: version, onlineVersion: version, policy: policy))
    }
}
