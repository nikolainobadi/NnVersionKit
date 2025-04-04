//
//  VersionNumberHandler.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import Foundation

public enum VersionNumberHandler {
    public static func compareVersions(deviceVersion: VersionNumber, onlineVersion: VersionNumber, selectedVersionNumberType: VersionNumberType) -> Bool {
        let majorUpdate = deviceVersion.majorNum < onlineVersion.majorNum
        let minorUpdate = deviceVersion.minorNum < onlineVersion.minorNum
        let patchUpdate = deviceVersion.patchNum < onlineVersion.patchNum
        
        switch selectedVersionNumberType {
        case .major:
            return majorUpdate
        case .minor:
            return majorUpdate || minorUpdate
        case .patch:
            return majorUpdate || minorUpdate || patchUpdate
        }
    }
}
