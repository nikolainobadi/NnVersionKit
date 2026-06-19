//
//  VersionCheckViewModifier.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import SwiftUI

struct VersionCheckViewModifier<UpdateView: View>: ViewModifier {
    @State var viewModel: VersionCheckViewModel

    let updateView: () -> UpdateView

    func body(content: Content) -> some View {
        if viewModel.versionUpdateRequired {
            updateView()
        } else {
            content
                .task {
                    await viewModel.checkVersions()
                }
        }
    }
}

/// Runs the version check and reports the result via `onStatus` without ever replacing the content.
/// Used by the report-only `checkingAppVersion` overloads where the client owns all presentation.
struct VersionStatusViewModifier: ViewModifier {
    @State var viewModel: VersionCheckViewModel

    func body(content: Content) -> some View {
        content
            .task {
                await viewModel.checkVersions()
            }
    }
}

public extension View {
    /// Adds a modifier to check the current app version against a remote source using the app's bundle.
    ///
    /// - Parameters:
    ///   - bundle: The bundle to extract the local version from.
    ///   - onlineVersionLoader: Optional custom loader for fetching the online version (defaults to App Store).
    ///   - updatePolicy: How far behind the latest version the device may fall before an update is forced (default is `.majorOnly`).
    ///   - debugEnabled: When `true`, prints version check details to the console. Nothing is printed when `false` (default).
    ///   - enableUITestSeeding: When `true`, a device/online version seeded via `NnVersionKitEnvironment` overrides the corresponding loader. Default `false`, so production never reads the environment.
    ///   - onStatus: Optional handler invoked after each check with the resolved status and the online version — use it to drive a non-blocking "update available" prompt.
    ///   - onError: Optional error handler for version check failures.
    ///   - updateView: A view to present when an update is required.
    func checkingAppVersion<UpdateView: View>(
        bundle: Bundle,
        onlineVersionLoader: VersionLoader? = nil,
        updatePolicy: VersionUpdatePolicy = .majorOnly,
        debugEnabled: Bool = false,
        enableUITestSeeding: Bool = false,
        onStatus: VersionStatusHandler? = nil,
        onError: ((Error) -> Void)? = nil,
        @ViewBuilder updateView: @escaping () -> UpdateView
    ) -> some View {
        modifier(
            VersionCheckViewModifier(
                viewModel: .customInit(bundle: bundle, onlineVersionLoader: onlineVersionLoader, policy: updatePolicy, debugEnabled: debugEnabled, enableUITestSeeding: enableUITestSeeding, onStatus: onStatus, onError: onError),
                updateView: updateView
            )
        )
    }

    /// Adds a modifier to check the current app version using custom version loaders.
    ///
    /// - Parameters:
    ///   - deviceVersionLoader: Loader for the local version (e.g., from bundle).
    ///   - onlineVersionLoader: Loader for the online version (e.g., from App Store).
    ///   - updatePolicy: How far behind the latest version the device may fall before an update is forced (default is `.majorOnly`).
    ///   - debugEnabled: When `true`, prints version check details to the console. Nothing is printed when `false` (default).
    ///   - onStatus: Optional handler invoked after each check with the resolved status and the online version — use it to drive a non-blocking "update available" prompt.
    ///   - onError: Optional error handler for version check failures.
    ///   - updateView: A view to present when an update is required.
    func checkingAppVersion<UpdateView: View>(
        deviceVersionLoader: VersionLoader,
        onlineVersionLoader: VersionLoader,
        updatePolicy: VersionUpdatePolicy = .majorOnly,
        debugEnabled: Bool = false,
        onStatus: VersionStatusHandler? = nil,
        onError: ((Error) -> Void)? = nil,
        @ViewBuilder updateView: @escaping () -> UpdateView
    ) -> some View {
        modifier(
            VersionCheckViewModifier(
                viewModel: .init(
                    deviceVersionLoader: deviceVersionLoader,
                    onlineVersionLoader: onlineVersionLoader,
                    policy: updatePolicy,
                    debugEnabled: debugEnabled,
                    onStatus: onStatus,
                    onError: onError
                ),
                updateView: updateView
            )
        )
    }

    /// Adds a version check that reports its result via `onStatus` and presents **no** UI itself.
    ///
    /// Use this when you want to own every state — including the forced update — and present it
    /// yourself (a `fullScreenCover`, navigation, a banner, etc.). The content is never replaced.
    ///
    /// - Parameters:
    ///   - bundle: The bundle to extract the local version from.
    ///   - onlineVersionLoader: Optional custom loader for fetching the online version (defaults to App Store).
    ///   - updatePolicy: How far behind the latest version the device may fall before the status becomes `.updateRequired` (default is `.majorOnly`).
    ///   - debugEnabled: When `true`, prints version check details to the console. Nothing is printed when `false` (default).
    ///   - enableUITestSeeding: When `true`, a device/online version seeded via `NnVersionKitEnvironment` overrides the corresponding loader. Default `false`.
    ///   - onError: Optional error handler for version check failures.
    ///   - onStatus: Handler invoked after each check with the resolved status and the online version.
    func checkingAppVersion(
        bundle: Bundle,
        onlineVersionLoader: VersionLoader? = nil,
        updatePolicy: VersionUpdatePolicy = .majorOnly,
        debugEnabled: Bool = false,
        enableUITestSeeding: Bool = false,
        onError: ((Error) -> Void)? = nil,
        onStatus: @escaping VersionStatusHandler
    ) -> some View {
        modifier(
            VersionStatusViewModifier(
                viewModel: .customInit(bundle: bundle, onlineVersionLoader: onlineVersionLoader, policy: updatePolicy, debugEnabled: debugEnabled, enableUITestSeeding: enableUITestSeeding, onStatus: onStatus, onError: onError)
            )
        )
    }

    /// Adds a version check using custom loaders that reports its result via `onStatus` and presents **no** UI itself.
    ///
    /// Use this when you want to own every state — including the forced update — and present it yourself.
    ///
    /// - Parameters:
    ///   - deviceVersionLoader: Loader for the local version (e.g., from bundle).
    ///   - onlineVersionLoader: Loader for the online version (e.g., from App Store).
    ///   - updatePolicy: How far behind the latest version the device may fall before the status becomes `.updateRequired` (default is `.majorOnly`).
    ///   - debugEnabled: When `true`, prints version check details to the console. Nothing is printed when `false` (default).
    ///   - onError: Optional error handler for version check failures.
    ///   - onStatus: Handler invoked after each check with the resolved status and the online version.
    func checkingAppVersion(
        deviceVersionLoader: VersionLoader,
        onlineVersionLoader: VersionLoader,
        updatePolicy: VersionUpdatePolicy = .majorOnly,
        debugEnabled: Bool = false,
        onError: ((Error) -> Void)? = nil,
        onStatus: @escaping VersionStatusHandler
    ) -> some View {
        modifier(
            VersionStatusViewModifier(
                viewModel: .init(deviceVersionLoader: deviceVersionLoader, onlineVersionLoader: onlineVersionLoader, policy: updatePolicy, debugEnabled: debugEnabled, onStatus: onStatus, onError: onError)
            )
        )
    }
}


// MARK: - Extension Dependencies
private extension VersionCheckViewModel {
    static func customInit(
        bundle: Bundle,
        onlineVersionLoader: VersionLoader?,
        policy: VersionUpdatePolicy,
        debugEnabled: Bool,
        enableUITestSeeding: Bool,
        onStatus: VersionStatusHandler?,
        onError: ((Error) -> Void)?
    ) -> VersionCheckViewModel {
        let seededDevice = enableUITestSeeding ? NnVersionKitEnvironment.seededDeviceLoader() : nil
        let seededOnline = enableUITestSeeding ? NnVersionKitEnvironment.seededOnlineLoader() : nil

        let deviceLoader = seededDevice ?? DeviceBundleVersionLoader(bundle: bundle, debugEnabled: debugEnabled)
        let onlineLoader = seededOnline ?? onlineVersionLoader ?? AppStoreVersionLoader(bundleId: bundle.bundleIdentifier, debugEnabled: debugEnabled)

        return .init(
            deviceVersionLoader: deviceLoader,
            onlineVersionLoader: onlineLoader,
            policy: policy,
            debugEnabled: debugEnabled,
            onStatus: onStatus,
            onError: onError
        )
    }
}
