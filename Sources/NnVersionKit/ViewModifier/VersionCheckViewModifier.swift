//
//  VersionCheckViewModifier.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 4/3/25.
//

import SwiftUI

struct VersionCheckViewModifier<UpdateView: View>: ViewModifier {
    @StateObject var viewModel: VersionCheckViewModel
    
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
    ///   - versionNumberUpdateType: The level of version comparison to trigger an update (default is `.major`).
    ///   - onError: Optional error handler for version check failures.
    ///   - updateView: A view to present when an update is required.
    func checkingAppVersion<UpdateView: View>(bundle: Bundle, onlineVersionLoader: VersionLoader? = nil, versionNumberUpdateType: VersionNumberType = .major, onError: ((Error) -> Void)? = nil, @ViewBuilder updateView: @escaping () -> UpdateView) -> some View {
        modifier(VersionCheckViewModifier(viewModel: .customInit(bundle: bundle, onlineVersionLoader: onlineVersionLoader, versionType: versionNumberUpdateType, onError: onError), updateView: updateView))
    }
    
    /// Adds a modifier to check the current app version using custom version loaders.
    ///
    /// - Parameters:
    ///   - deviceVersionLoader: Loader for the local version (e.g., from bundle).
    ///   - onlineVersionLoader: Loader for the online version (e.g., from App Store).
    ///   - versionNumberUpdateType: The level of version comparison to trigger an update (default is `.major`).
    ///   - onError: Optional error handler for version check failures.
    ///   - updateView: A view to present when an update is required.
    func checkingAppVersion<UpdateView: View>(deviceVersionLoader: VersionLoader, onlineVersionLoader: VersionLoader, versionNumberUpdateType: VersionNumberType = .major, onError: ((Error) -> Void)? = nil, @ViewBuilder updateView: @escaping () -> UpdateView) -> some View {
        modifier(VersionCheckViewModifier(viewModel: .init(deviceVersionLoader: deviceVersionLoader, onlineVersionLoader: onlineVersionLoader, selectedVersionNumberType: versionNumberUpdateType, onError: onError), updateView: updateView))
    }
}


// MARK: - Extension Dependencies
fileprivate extension VersionCheckViewModel {
    static func customInit(bundle: Bundle, onlineVersionLoader: VersionLoader?, versionType: VersionNumberType, onError: ((Error) -> Void)?) -> VersionCheckViewModel {
        let deviceLoader = DeviceBundleVersionLoader(bundle: bundle)
        let onlineLoader = onlineVersionLoader ?? AppStoreVersionLoader(bundleId: bundle.bundleIdentifier)
        
        return .init(deviceVersionLoader: deviceLoader, onlineVersionLoader: onlineLoader, selectedVersionNumberType: versionType, onError: onError)
    }
}
