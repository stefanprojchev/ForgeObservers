/// The user's current push notification permission status.
public enum NotificationPermissionStatus: Sendable {
    /// The user has not yet been asked for permission.
    case notDetermined

    /// Full notification permission granted.
    case authorized

    /// The user explicitly denied permission.
    case denied

    /// Provisional (quiet) notification permission.
    case provisional

    /// Ephemeral notification permission (App Clips).
    case ephemeral
}
