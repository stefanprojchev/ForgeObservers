import os
import UIKit

/// Monitors light/dark mode changes via `UITraitCollection`.
///
/// Requires `@MainActor` for initialization.
public final class AppearanceObserver: AppearanceObserving, Sendable {
    private struct LockedState: Sendable {
        var current: AppAppearance
        var continuations: [UUID: AsyncStream<AppAppearance>.Continuation] = [:]
    }

    private let lock: OSAllocatedUnfairLock<LockedState>
    nonisolated(unsafe) private var token: (any NSObjectProtocol)?

    // MARK: - Initialization

    /// Creates the observer and begins monitoring appearance changes.
    @MainActor
    public init() {
        let appearance: AppAppearance =
            UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
        lock = OSAllocatedUnfairLock(initialState: LockedState(current: appearance))

        token = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let appearance: AppAppearance =
                UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light

            let continuations = self.lock.withLock { state -> [AsyncStream<AppAppearance>.Continuation] in
                guard state.current != appearance else { return [] }
                state.current = appearance
                return Array(state.continuations.values)
            }

            for continuation in continuations {
                continuation.yield(appearance)
            }
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

    public var current: AppAppearance {
        lock.withLock { $0.current }
    }

    // MARK: - Stream

    public var appearanceStream: AsyncStream<AppAppearance> {
        let id = UUID()
        return AsyncStream { continuation in
            continuation.onTermination = { [weak self] _ in
                self?.lock.withLock { $0.continuations[id] = nil }
            }

            let current = self.lock.withLock { state -> AppAppearance in
                state.continuations[id] = continuation
                return state.current
            }
            continuation.yield(current)
        }
    }
}
