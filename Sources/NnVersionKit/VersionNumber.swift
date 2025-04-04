//
//  VersionNumber.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

public struct VersionNumber: Equatable, Sendable {
    public let majorNum: Int
    public let minorNum: Int
    public let patchNum: Int
    
    public init(majorNum: Int, minorNum: Int, patchNum: Int) {
        self.majorNum = majorNum
        self.minorNum = minorNum
        self.patchNum = patchNum
    }
}
