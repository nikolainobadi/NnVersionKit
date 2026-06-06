//
//  VersionCheckViewModel.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import Foundation
import Observation

/// View model responsible for checking and comparing the app's version against a remote version source.
@MainActor
@Observable
final class VersionCheckViewModel {
    /// Indicates whether a version update is required.
    var versionUpdateRequired = false

    private let debugEnabled: Bool
    private let onError: ((Error) -> Void)?
    private let deviceVersionLoader: any VersionLoader
    private let onlineVersionLoader: any VersionLoader
    private let selectedVersionNumberType: VersionNumberType

    /// Initializes the view model with custom version loaders and error handling.
    ///
    /// - Parameters:
    ///   - deviceVersionLoader: Loader for retrieving the local version.
    ///   - onlineVersionLoader: Loader for retrieving the remote version.
    ///   - selectedVersionNumberType: Determines the level of version comparison (e.g., major, minor, patch).
    ///   - debugEnabled: When `true`, prints version check details to the console. Nothing is printed when `false`.
    ///   - onError: Optional error handler for reporting load or comparison failures.
    init(
        deviceVersionLoader: any VersionLoader,
        onlineVersionLoader: any VersionLoader,
        selectedVersionNumberType: VersionNumberType,
        debugEnabled: Bool = false,
        onError: ((Error) -> Void)?
    ) {
        self.onError = onError
        self.debugEnabled = debugEnabled
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
            log("Starting version check (comparison level: \(selectedVersionNumberType))")
            let deviceVersion = try await deviceVersionLoader.loadVersionNumber()
            log("Loaded device version: \(deviceVersion.stringFormat)")
            let onlineVersion = try await onlineVersionLoader.loadVersionNumber()
            log("Loaded online version: \(onlineVersion.stringFormat)")

            versionUpdateRequired = VersionNumberHandler.versionUpdateIsRequired(
                deviceVersion: deviceVersion,
                onlineVersion: onlineVersion,
                selectedVersionNumberType: selectedVersionNumberType,
                debugEnabled: debugEnabled
            )
            log("Version update required: \(versionUpdateRequired)")
        } catch {
            log("Version check failed: \(error.localizedDescription)")
            onError?(error)
        }
    }
}


// MARK: - Private Methods
private extension VersionCheckViewModel {
    /// Prints a message to the console when debug logging is enabled.
    ///
    /// - Parameter message: The message to print.
    func log(_ message: String) {
        VersionKitLogger.log(message, isEnabled: debugEnabled)
    }
}
