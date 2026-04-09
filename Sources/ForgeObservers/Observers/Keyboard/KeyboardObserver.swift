import os
import UIKit

/// Monitors keyboard visibility and frame via `UIResponder` notifications.
public final class KeyboardObserver: KeyboardObserving, Sendable {
    private struct LockedState: Sendable {
        var state: KeyboardState = .hidden
        var continuations: [UUID: AsyncStream<KeyboardState>.Continuation] = [:]
    }

    private let lock = OSAllocatedUnfairLock(initialState: LockedState())
    nonisolated(unsafe) private var tokens: [any NSObjectProtocol] = []
    private let notificationCenter: NotificationCenter

    // MARK: - Initialization

    /// Creates the observer and begins monitoring keyboard visibility changes.
    /// - Parameter notificationCenter: The notification center to subscribe to. Defaults to `.default`.
    ///   Pass a fresh `NotificationCenter()` in tests to observe posted notifications in isolation.
    public init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        tokens = [
            notificationCenter.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                let state = Self.parse(notification: notification, visible: true)
                self?.broadcast(state)
            },
            notificationCenter.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                let duration = notification.userInfo?[
                    UIResponder.keyboardAnimationDurationUserInfoKey
                ] as? TimeInterval ?? 0.25

                let state = KeyboardState(
                    isVisible: false,
                    height: 0,
                    animationDuration: duration
                )

                self?.broadcast(state)
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

    public var state: KeyboardState {
        lock.withLock { $0.state }
    }

    // MARK: - Stream

    public var stateStream: AsyncStream<KeyboardState> {
        let id = UUID()
        return AsyncStream { continuation in
            continuation.onTermination = { [weak self] _ in
                self?.lock.withLock { $0.continuations[id] = nil }
            }

            let current = self.lock.withLock { state -> KeyboardState in
                state.continuations[id] = continuation
                return state.state
            }
            continuation.yield(current)
        }
    }

    // MARK: - Private

    private func broadcast(_ newState: KeyboardState) {
        let continuations = lock.withLock { state -> [AsyncStream<KeyboardState>.Continuation] in
            state.state = newState
            return Array(state.continuations.values)
        }
        for continuation in continuations {
            continuation.yield(newState)
        }
    }

    private static func parse(notification: Notification, visible: Bool) -> KeyboardState {
        let frame = notification.userInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
        ] as? CGRect ?? .zero

        let duration = notification.userInfo?[
            UIResponder.keyboardAnimationDurationUserInfoKey
        ] as? TimeInterval ?? 0.25

        return KeyboardState(
            isVisible: visible,
            height: frame.height,
            animationDuration: duration
        )
    }
}
