//
//  VersionCheckViewModel.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import Foundation

@MainActor
final class VersionCheckViewModel: ObservableObject {
    @Published var versionUpdateRequired = false
    
    private let onError: ((Error) -> Void)?
    private let deviceVersionLoader: VersionLoader
    private let onlineVersionLoader: VersionLoader
    private let selectedVersionNumberType: VersionNumberType
    
    init(deviceVersionLoader: VersionLoader, onlineVersionLoader: VersionLoader, selectedVersionNumberType: VersionNumberType, onError: ((Error) -> Void)?) {
        self.onError = onError
        self.deviceVersionLoader = deviceVersionLoader
        self.onlineVersionLoader = onlineVersionLoader
        self.selectedVersionNumberType = selectedVersionNumberType
    }
}


// MARK: - Actions
extension VersionCheckViewModel {
    func checkVersions() async {
        do {
            let deviceVersion = try await deviceVersionLoader.loadVersionNumber()
            let onlineVersion = try await onlineVersionLoader.loadVersionNumber()
                        
            versionUpdateRequired = VersionNumberHandler.compareVersions(deviceVersion: deviceVersion, onlineVersion: onlineVersion, selectedVersionNumberType: selectedVersionNumberType)
        } catch {
            print(error.localizedDescription)
            onError?(error)
        }
    }
}


// MARK: - Dependencies
public protocol VersionLoader: Sendable {
    func loadVersionNumber() async throws -> VersionNumber
}
