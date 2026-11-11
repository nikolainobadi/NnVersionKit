public enum VersionKitError: Error {
    case missingNumber
    case invalidBundleId
    case missingDeviceVersionString
    case unableToFetchVersionFromAppStore
}
