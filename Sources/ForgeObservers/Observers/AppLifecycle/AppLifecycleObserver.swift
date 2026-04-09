import os
import UIKit

/// Monitors app lifecycle transitions via `UIApplication` notifications.
public final class AppLifecycleObserver: AppLifecycleObserving, Sendable {
    private struct LockedState: Sendable {
        var state: AppLifecycleState = .active
        var continuations: [UUID: AsyncStream<AppLifecycleState>.Continuation] = [:]
    }

    private let lock = OSAllocatedUnfairLock(initialState: LockedState())
    nonisolated(unsafe) private var tokens: [any NSObjectProtocol] = []
    private let notificationCenter: NotificationCenter

    // MARK: - Initialization

    /// Creates the observer and begins monitoring app lifecycle transitions.
    /// - Parameter notificationCenter: The notification center to subscribe to. Defaults to `.default`.
    ///   Pass a fresh `NotificationCenter()` in tests to observe posted notifications in isolation.
    public init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        tokens = [
            notificationCenter.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.broadcast(.active)
            },
            notificationCenter.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.broadcast(.inactive)
            },
            notificationCenter.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.broadcast(.background)
            }
        ]
    }

    deinit {
        tokens.forEach { notificationCenter.removeObserver($0) }
        let continuations = lock.withLock { Array($0.continuations.values) }
        for continuation in continuations {
            continuation.finish()
        }
    }

    // MARK: - Properties

    public var state: AppLifecycleState {
        lock.withLock { $0.state }
    }

    // MARK: - Stream

    public var stateStream: AsyncStream<AppLifecycleState> {
        let id = UUID()
        return AsyncStream { continuation in
            continuation.onTermination = { [weak self] _ in
                self?.lock.withLock { $0.continuations[id] = nil }
            }

            let current = self.lock.withLock { state -> AppLifecycleState in
                state.continuations[id] = continuation
                return state.state
            }
            continuation.yield(current)
        }
    }

    // MARK: - Private

    private func broadcast(_ newState: AppLifecycleState) {
        let continuations = lock.withLock { state -> [AsyncStream<AppLifecycleState>.Continuation] in
            state.state = newState
            return Array(state.continuations.values)
        }
        for continuation in continuations {
            continuation.yield(newState)
        }
    }
}
