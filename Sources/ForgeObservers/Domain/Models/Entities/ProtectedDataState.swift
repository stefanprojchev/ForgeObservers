/// Whether iOS-protected data is accessible.
public enum ProtectedDataState: Sendable {
    /// Device is unlocked or has no passcode.
    case available

    /// Device is locked with a passcode.
    case unavailable
}
