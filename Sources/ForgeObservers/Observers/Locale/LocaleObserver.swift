import Foundation
import os

/// Monitors locale changes via `NSLocale.currentLocaleDidChangeNotification`.
public final class LocaleObserver: LocaleObserving, Sendable {
    private struct LockedState: Sendable {
        var current: AppLocale
        var continuations: [UUID: AsyncStream<AppLocale>.Continuation] = [:]
    }

    private let lock: OSAllocatedUnfairLock<LockedState>
    nonisolated(unsafe) private var token: (any NSObjectProtocol)?
    private let notificationCenter: NotificationCenter
    private let localeProvider: @Sendable () -> AppLocale

    // MARK: - Initialization

    /// Creates the observer and begins monitoring locale changes.
    /// - Parameters:
    ///   - notificationCenter: The notification center to subscribe to. Defaults to `.default`.
    ///   - localeProvider: Closure that returns the current `AppLocale`. Defaults to creating
    ///     a fresh `AppLocale()`. Tests can inject a stub that returns synthetic values.
    public init(
        notificationCenter: NotificationCenter = .default,
        localeProvider: @escaping @Sendable () -> AppLocale = { AppLocale() }
    ) {
        self.notificationCenter = notificationCenter
        self.localeProvider = localeProvider
        lock = OSAllocatedUnfairLock(initialState: LockedState(current: localeProvider()))

        token = notificationCenter.addObserver(
            forName: NSLocale.currentLocaleDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let locale = self.localeProvider()

            let continuations = self.lock.withLock { state -> [AsyncStream<AppLocale>.Continuation] in
                guard state.current != locale else { return [] }
                state.current = locale
                return Array(state.continuations.values)
            }

            for continuation in continuations {
                continuation.yield(locale)
            }
        }
    }

    deinit {
        if let token { notificationCenter.removeObserver(token) }
        let continuations = lock.withLock { Array($0.continuations.values) }
        for continuation in continuations {
            continuation.finish()
        }
    }

    // MARK: - Properties

    public var current: AppLocale {
        lock.withLock { $0.current }
    }

    // MARK: - Stream

    public var localeStream: AsyncStream<AppLocale> {
        let id = UUID()
        return AsyncStream { continuation in
            continuation.onTermination = { [weak self] _ in
                self?.lock.withLock { $0.continuations[id] = nil }
            }

            let current = self.lock.withLock { state -> AppLocale in
                state.continuations[id] = continuation
                return state.current
            }
            continuation.yield(current)
        }
    }
}
