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
    func checkingAppVersion<UpdateView: View>(bundle: Bundle, onlineVersionLoader: VersionLoader? = nil, versionNumberUpdateType: VersionNumberType = .major, onError: ((Error) -> Void)? = nil, @ViewBuilder updateView: @escaping () -> UpdateView) -> some View {
        modifier(VersionCheckViewModifier(viewModel: .customInit(bundle: bundle, onlineVersionLoader: onlineVersionLoader, versionType: versionNumberUpdateType, onError: onError), updateView: updateView))
    }
    
    func checkingAppVersion<UpdateView: View>(deviceVersionLoader: VersionLoader, onlineVersionLoader: VersionLoader, versionNumberUpdateType: VersionNumberType = .major, onError: ((Error) -> Void)? = nil, @ViewBuilder updateView: @escaping () -> UpdateView) -> some View {
        modifier(VersionCheckViewModifier(viewModel: .init(deviceVersionLoader: deviceVersionLoader, onlineVersionLoader: onlineVersionLoader, selectedVersionNumberType: versionNumberUpdateType, onError: onError), updateView: updateView))
    }
}


// MARK: - Extension Dependencies
fileprivate extension VersionCheckViewModel {
    static func customInit(bundle: Bundle, onlineVersionLoader: VersionLoader?, versionType: VersionNumberType, onError: ((Error) -> Void)?) -> VersionCheckViewModel {
        let deviceLoader = DeviceBundleVersionStore(bundle: bundle)
        let onlineLoader = onlineVersionLoader ?? AppStoreVersionLoader(bundleId: bundle.bundleIdentifier)
        
        return .init(deviceVersionLoader: deviceLoader, onlineVersionLoader: onlineLoader, selectedVersionNumberType: versionType, onError: onError)
    }
}
