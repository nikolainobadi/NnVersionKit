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
    /// The latest classification of the device version against the online version.
    var status: VersionUpdateStatus = .upToDate

    /// Indicates whether a version update is required.
    var versionUpdateRequired: Bool { status == .updateRequired }

    private let debugEnabled: Bool
    private let onError: ((Error) -> Void)?
    private let onStatus: ((VersionUpdateStatus, VersionNumber) -> Void)?
    private let deviceVersionLoader: any VersionLoader
    private let onlineVersionLoader: any VersionLoader
    private let policy: VersionUpdatePolicy

    /// Initializes the view model with custom version loaders and error handling.
    ///
    /// - Parameters:
    ///   - deviceVersionLoader: Loader for retrieving the local version.
    ///   - onlineVersionLoader: Loader for retrieving the remote version.
    ///   - policy: Determines how far behind the latest version the device may fall before an update is forced.
    ///   - debugEnabled: When `true`, prints version check details to the console. Nothing is printed when `false`.
    ///   - onStatus: Optional handler invoked after each successful check with the resolved status and the online version.
    ///   - onError: Optional error handler for reporting load or comparison failures.
    init(
        deviceVersionLoader: any VersionLoader,
        onlineVersionLoader: any VersionLoader,
        policy: VersionUpdatePolicy,
        debugEnabled: Bool = false,
        onStatus: ((VersionUpdateStatus, VersionNumber) -> Void)? = nil,
        onError: ((Error) -> Void)?
    ) {
        self.onError = onError
        self.onStatus = onStatus
        self.debugEnabled = debugEnabled
        self.deviceVersionLoader = deviceVersionLoader
        self.onlineVersionLoader = onlineVersionLoader
        self.policy = policy
    }
}


// MARK: - Actions
extension VersionCheckViewModel {
    /// Asynchronously checks the device and online versions, and updates the `versionUpdateRequired` flag.
    ///
    /// - Note: Invokes the `onError` handler if an error occurs during loading or comparison.
    func checkVersions() async {
        do {
            log("Starting version check (policy: \(policy))")
            let deviceVersion = try await deviceVersionLoader.loadVersionNumber()
            log("Loaded device version: \(deviceVersion.stringFormat)")
            let onlineVersion = try await onlineVersionLoader.loadVersionNumber()
            log("Loaded online version: \(onlineVersion.stringFormat)")

            status = VersionNumberHandler.versionStatus(
                deviceVersion: deviceVersion,
                onlineVersion: onlineVersion,
                policy: policy,
                debugEnabled: debugEnabled
            )
            log("Version status: \(status)")
            onStatus?(status, onlineVersion)
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
