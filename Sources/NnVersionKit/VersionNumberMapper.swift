//
//  VersionNumberMapper.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

enum VersionNumberMapper {
    static func map(_ versionString: String) throws -> VersionNumber {
        let noDecimals = versionString.components(separatedBy: ".")
        let array = noDecimals.compactMap { Int($0) }
        
        guard array.count == noDecimals.count else {
            throw VersionKitError.missingNumber
        }
        
        return makeVersionNumber(from: array)
    }
}


// MARK: - Private
private extension VersionNumberMapper {
    static func makeVersionNumber(from array: [Int]) -> VersionNumber {
        return .init(majorNum: getNumber(.major, in: array), minorNum: getNumber(.minor, in: array), patchNum: getNumber(.patch, in: array))
    }
    
    static func getNumber(_ numtype: VersionNumberType, in array: [Int]) -> Int {
        let index = numtype.rawValue
        
        return array.count > index ? array[index] : 0
    }
}
