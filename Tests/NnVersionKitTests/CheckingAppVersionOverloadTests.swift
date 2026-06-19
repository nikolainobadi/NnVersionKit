//
//  CheckingAppVersionOverloadTests.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 6/19/25.
//
//  Compile-only coverage: confirms the presenting and report-only `checkingAppVersion`
//  overloads resolve unambiguously at the call site.

#if canImport(SwiftUI)
import SwiftUI
@testable import NnVersionKit

private struct OverloadResolutionView: View {
    @State private var forcedUpdate: VersionNumber?

    var body: some View {
        Color.clear
            // Presenting overload: trailing updateView closure.
            .checkingAppVersion(bundle: .main) {
                Text("Please update")
            }
            // Presenting overload with a soft-nudge status handler alongside updateView.
            .checkingAppVersion(bundle: .main, onStatus: { _, _ in }) {
                Text("Please update")
            }
            // Report-only overload: onStatus, no updateView. Client owns presentation.
            .checkingAppVersion(bundle: .main, onStatus: { status, version in
                forcedUpdate = status == .updateRequired ? version : nil
            })
            // VersionNumber: Identifiable drives item-based presentation (sheet here for
            // cross-platform compilation; iOS apps typically use fullScreenCover for a forced update).
            .sheet(item: $forcedUpdate) { version in
                Text("Update to \(version.stringFormat)")
            }
    }
}
#endif
