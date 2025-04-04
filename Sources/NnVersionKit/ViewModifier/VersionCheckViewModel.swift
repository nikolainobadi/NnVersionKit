//
//  VersionCheckViewModel.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import Foundation

/// View model responsible for checking and comparing the app's version against a remote version source.
@MainActor
final class VersionCheckViewModel: ObservableObject {
    /// Indicates whether a version update is required.
    @Published var versionUpdateRequired = false

    private let onError: ((Error) -> Void)?
    private let deviceVersionLoader: VersionLoader
    private let onlineVersionLoader: VersionLoader
    private let selectedVersionNumberType: VersionNumberType

    /// Initializes the view model with custom version loaders and error handling.
    ///
    /// - Parameters:
    ///   - deviceVersionLoader: Loader for retrieving the local version.
    ///   - onlineVersionLoader: Loader for retrieving the remote version.
    ///   - selectedVersionNumberType: Determines the level of version comparison (e.g., major, minor, patch).
    ///   - onError: Optional error handler for reporting load or comparison failures.
    init(
        deviceVersionLoader: VersionLoader,
        onlineVersionLoader: VersionLoader,
        selectedVersionNumberType: VersionNumberType,
        onError: ((Error) -> Void)?
    ) {
        self.onError = onError
        self.deviceVersionLoader = deviceVersionLoader
        self.onlineVersionLoader = onlineVersionLoader
        self.selectedVersionNumberType = selectedVersionNumberType
    }
}

// MARK: - Actions
extension VersionCheckViewModel {
    /// Asynchronously checks the device and online versions, and updates the `versionUpdateRequired` flag.
    ///
    /// - Note: Invokes the `onError` handler if an error occurs during loading or comparison.
    func checkVersions() async {
        do {
            let deviceVersion = try await deviceVersionLoader.loadVersionNumber()
            let onlineVersion = try await onlineVersionLoader.loadVersionNumber()

            versionUpdateRequired = VersionNumberHandler.compareVersions(
                deviceVersion: deviceVersion,
                onlineVersion: onlineVersion,
                selectedVersionNumberType: selectedVersionNumberType
            )
        } catch {
            print(error.localizedDescription)
            onError?(error)
        }
    }
}
