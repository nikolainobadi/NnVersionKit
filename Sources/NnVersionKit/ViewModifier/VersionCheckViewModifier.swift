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
    func checkingAppVersion<UpdateView: View>(bundle: Bundle, onlineVersionLoader: VersionLoader? = nil, updatePolicy: VersionUpdatePolicy = .majorOnly, debugEnabled: Bool = false, enableUITestSeeding: Bool = false, onStatus: ((VersionUpdateStatus, VersionNumber) -> Void)? = nil, onError: ((Error) -> Void)? = nil, @ViewBuilder updateView: @escaping () -> UpdateView) -> some View {
        modifier(VersionCheckViewModifier(viewModel: .customInit(bundle: bundle, onlineVersionLoader: onlineVersionLoader, policy: updatePolicy, debugEnabled: debugEnabled, enableUITestSeeding: enableUITestSeeding, onStatus: onStatus, onError: onError), updateView: updateView))
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
    func checkingAppVersion<UpdateView: View>(deviceVersionLoader: VersionLoader, onlineVersionLoader: VersionLoader, updatePolicy: VersionUpdatePolicy = .majorOnly, debugEnabled: Bool = false, onStatus: ((VersionUpdateStatus, VersionNumber) -> Void)? = nil, onError: ((Error) -> Void)? = nil, @ViewBuilder updateView: @escaping () -> UpdateView) -> some View {
        modifier(VersionCheckViewModifier(viewModel: .init(deviceVersionLoader: deviceVersionLoader, onlineVersionLoader: onlineVersionLoader, policy: updatePolicy, debugEnabled: debugEnabled, onStatus: onStatus, onError: onError), updateView: updateView))
    }
}


// MARK: - Extension Dependencies
fileprivate extension VersionCheckViewModel {
    static func customInit(bundle: Bundle, onlineVersionLoader: VersionLoader?, policy: VersionUpdatePolicy, debugEnabled: Bool, enableUITestSeeding: Bool, onStatus: ((VersionUpdateStatus, VersionNumber) -> Void)?, onError: ((Error) -> Void)?) -> VersionCheckViewModel {
        let seededDevice = enableUITestSeeding ? NnVersionKitEnvironment.seededDeviceLoader() : nil
        let seededOnline = enableUITestSeeding ? NnVersionKitEnvironment.seededOnlineLoader() : nil

        let deviceLoader = seededDevice ?? DeviceBundleVersionLoader(bundle: bundle, debugEnabled: debugEnabled)
        let onlineLoader = seededOnline ?? onlineVersionLoader ?? AppStoreVersionLoader(bundleId: bundle.bundleIdentifier, debugEnabled: debugEnabled)

        return .init(deviceVersionLoader: deviceLoader, onlineVersionLoader: onlineLoader, policy: policy, debugEnabled: debugEnabled, onStatus: onStatus, onError: onError)
    }
}
