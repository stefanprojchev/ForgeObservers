import UserNotifications

/// Observes push notification permission status. Re-checks on each app foreground event.
public protocol NotificationPermissionObserving: Sendable {
    /// The current permission status. Thread-safe.
    var status: NotificationPermissionStatus { get }

    /// Stream of permission status changes. Re-checks on every app foreground event.
    var statusStream: AsyncStream<NotificationPermissionStatus> { get }

    /// Forces a fresh check against `UNUserNotificationCenter`. Called automatically on app foreground.
    func refresh() async
}

// MARK: - Helpers

public extension NotificationPermissionObserving {
    /// Whether the user has granted some form of permission (full, provisional, or ephemeral).
    var isGranted: Bool {
        switch status {
        case .authorized, .provisional, .ephemeral:
            true
        case .notDetermined, .denied:
            false
        }
    }

    /// Whether the user hasn't been asked yet.
    var canRequestPermission: Bool {
        status == .notDetermined
    }

    /// Whether the user explicitly denied permission.
    var isDenied: Bool {
        status == .denied
    }
}
