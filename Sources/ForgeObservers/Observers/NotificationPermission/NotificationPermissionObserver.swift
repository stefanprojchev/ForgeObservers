import os
import UIKit
import UserNotifications

/// Monitors push notification permission by re-checking `UNUserNotificationCenter`
/// on each foreground transition.
public final class NotificationPermissionObserver: NotificationPermissionObserving, Sendable {
    private struct LockedState: Sendable {
        var status: NotificationPermissionStatus = .notDetermined
        var continuations: [UUID: AsyncStream<NotificationPermissionStatus>.Continuation] = [:]
    }

    private let lock = OSAllocatedUnfairLock(initialState: LockedState())
    nonisolated(unsafe) private var token: (any NSObjectProtocol)?

    // MARK: - Initialization

    /// Creates the observer and performs an initial permission check.
    public init() {
        token = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.refresh()
            }
        }

        Task { [weak self] in
            await self?.refresh()
        }
    }

    deinit {
        if let token { NotificationCenter.default.removeObserver(token) }
        let continuations = lock.withLock { Array($0.continuations.values) }
        for continuation in continuations {
            continuation.finish()
        }
    }

    // MARK: - Properties

    public var status: NotificationPermissionStatus {
        lock.withLock { $0.status }
    }

    // MARK: - Stream

    public var statusStream: AsyncStream<NotificationPermissionStatus> {
        let id = UUID()
        return AsyncStream { continuation in
            continuation.onTermination = { [weak self] _ in
                self?.lock.withLock { $0.continuations[id] = nil }
            }

            let current = self.lock.withLock { state -> NotificationPermissionStatus in
                state.continuations[id] = continuation
                return state.status
            }
            continuation.yield(current)
        }
    }

    // MARK: - Public

    /// Fetches the current notification authorization status and broadcasts any change.
    public func refresh() async {
        let settings = await UNUserNotificationCenter
            .current()
            .notificationSettings()

        let newStatus = Self.map(settings.authorizationStatus)

        let continuations = lock.withLock { state -> [AsyncStream<NotificationPermissionStatus>.Continuation] in
            let changed = state.status != newStatus
            state.status = newStatus
            return changed ? Array(state.continuations.values) : []
        }

        for continuation in continuations {
            continuation.yield(newStatus)
        }
    }

    // MARK: - Private

    private static func map(_ status: UNAuthorizationStatus) -> NotificationPermissionStatus {
        switch status {
        case .notDetermined: .notDetermined
        case .denied: .denied
        case .authorized: .authorized
        case .provisional: .provisional
        case .ephemeral: .ephemeral
        @unknown default: .denied
        }
    }
}
