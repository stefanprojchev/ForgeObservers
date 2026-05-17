import os
import UIKit

/// Monitors protected data availability via `UIApplication` notifications.
///
/// Requires `@MainActor` for initialization.
public final class ProtectedDataObserver: ProtectedDataObserving, Sendable {

    // MARK: - Dependencies

    private struct LockedState: Sendable {
        var state: ProtectedDataState
        var continuations: [UUID: AsyncStream<ProtectedDataState>.Continuation] = [:]
    }

    private let lock: OSAllocatedUnfairLock<LockedState>
    nonisolated(unsafe) private var tokens: [any NSObjectProtocol] = []
    private let notificationCenter: NotificationCenter

    // MARK: - Init

    /// Creates the observer and begins monitoring protected data availability.
    /// - Parameters:
    ///   - notificationCenter: The notification center to subscribe to. Defaults to `.default`.
    ///   - initialState: The initial protected data state. Defaults to reading
    ///     `UIApplication.shared.isProtectedDataAvailable` (requires `@MainActor`).
    ///     Tests can pass an explicit initial state to avoid `UIApplication.shared` access.
    @MainActor
    public init(
        notificationCenter: NotificationCenter = .default,
        initialState: ProtectedDataState? = nil
    ) {
        self.notificationCenter = notificationCenter
        let resolvedInitial: ProtectedDataState = initialState ?? (
            UIApplication.shared.isProtectedDataAvailable ? .available : .unavailable
        )
        lock = OSAllocatedUnfairLock(initialState: LockedState(state: resolvedInitial))

        tokens = [
            notificationCenter.addObserver(
                forName: UIApplication.protectedDataDidBecomeAvailableNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.broadcast(.available)
            },
            notificationCenter.addObserver(
                forName: UIApplication.protectedDataWillBecomeUnavailableNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.broadcast(.unavailable)
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

    // MARK: - Implementation

    public var state: ProtectedDataState {
        lock.withLock { $0.state }
    }

    public var stateStream: AsyncStream<ProtectedDataState> {
        let id = UUID()
        return AsyncStream { continuation in
            continuation.onTermination = { [weak self] _ in
                self?.lock.withLock { $0.continuations[id] = nil }
            }

            let current = self.lock.withLock { state -> ProtectedDataState in
                state.continuations[id] = continuation
                return state.state
            }
            continuation.yield(current)
        }
    }

    /// Suspends until protected data becomes available, returning immediately if it already is.
    public func waitUntilAvailable() async {
        for await state in stateStream {
            if state == .available { return }
        }
    }

    // MARK: - Private

    private func broadcast(_ newState: ProtectedDataState) {
        let continuations = lock.withLock { state -> [AsyncStream<ProtectedDataState>.Continuation] in
            state.state = newState
            return Array(state.continuations.values)
        }
        for continuation in continuations {
            continuation.yield(newState)
        }
    }
}
