import ForgeObservers
import os

final class MockNotificationPermissionObserver: NotificationPermissionObserving, Sendable {
    private struct LockedState: Sendable {
        var status: NotificationPermissionStatus
        var continuation: AsyncStream<NotificationPermissionStatus>.Continuation?
        var refreshHandler: (@Sendable () async -> NotificationPermissionStatus)?
    }

    private let lock: OSAllocatedUnfairLock<LockedState>

    // MARK: - Initialization

    init(status: NotificationPermissionStatus = .notDetermined) {
        lock = OSAllocatedUnfairLock(initialState: LockedState(status: status))
    }

    // MARK: - Properties

    var status: NotificationPermissionStatus {
        lock.withLock { $0.status }
    }

    // MARK: - Stream

    var statusStream: AsyncStream<NotificationPermissionStatus> {
        let (stream, continuation) = AsyncStream.makeStream(of: NotificationPermissionStatus.self)
        lock.withLock { $0.continuation = continuation }
        continuation.yield(status)
        return stream
    }

    // MARK: - Public

    func refresh() async {
        let handler = lock.withLock { $0.refreshHandler }
        if let handler {
            let newStatus = await handler()
            send(newStatus)
        }
    }

    // MARK: - Test Helpers

    func send(_ status: NotificationPermissionStatus) {
        lock.withLock {
            $0.status = status
            _ = $0.continuation?.yield(status)
        }
    }

    /// Sets a handler that `refresh()` will call to determine the new status.
    func onRefresh(_ handler: @escaping @Sendable () async -> NotificationPermissionStatus) {
        lock.withLock { $0.refreshHandler = handler }
    }
}
