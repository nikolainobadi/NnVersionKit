//
//  VersionNumberHandler.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import Foundation

public enum VersionNumberHandler {
    public static func makeNumber(from versionString: String) throws -> VersionNumber {
        let noDecimals = versionString.components(separatedBy: ".")
        let array = noDecimals.compactMap { Int($0) }
        
        guard array.count == noDecimals.count else {
            throw VersionKitError.missingNumber
        }
        
        return makeVersionNumber(from: array)
    }
    
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


// MARK: - Private
private extension VersionNumberHandler {
    static func makeVersionNumber(from array: [Int]) -> VersionNumber {
        return .init(majorNum: getNumber(.major, in: array), minorNum: getNumber(.minor, in: array), patchNum: getNumber(.patch, in: array))
    }
    
    static func getNumber(_ numtype: VersionNumberType, in array: [Int]) -> Int {
        let index = numtype.rawValue
        
        return array.count > index ? array[index] : 0
    }
}
