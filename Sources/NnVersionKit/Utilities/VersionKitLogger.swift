//
//  VersionKitLogger.swift
//  NnVersionKit
//
//  Created by Nikolai Nobadi on 6/6/26.
//

/// Internal helper for printing debug messages to the console.
enum VersionKitLogger {
    /// Prints a message to the console when debug logging is enabled.
    ///
    /// - Parameters:
    ///   - message: The message to print.
    ///   - isEnabled: When `false`, nothing is printed.
    static func log(_ message: String, isEnabled: Bool) {
        if isEnabled {
            print("[NnVersionKit] \(message)")
        }
    }
}
