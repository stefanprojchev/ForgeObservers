import ForgeObservers
import os

final class MockLocaleObserver: LocaleObserving, Sendable {
    private struct LockedState: Sendable {
        var current: AppLocale
        var continuation: AsyncStream<AppLocale>.Continuation?
    }

    private let lock: OSAllocatedUnfairLock<LockedState>

    // MARK: - Initialization

    init(current: AppLocale = AppLocale()) {
        lock = OSAllocatedUnfairLock(initialState: LockedState(current: current))
    }

    // MARK: - Properties

    var current: AppLocale {
        lock.withLock { $0.current }
    }

    // MARK: - Stream

    var localeStream: AsyncStream<AppLocale> {
        let (stream, continuation) = AsyncStream.makeStream(of: AppLocale.self)
        lock.withLock { $0.continuation = continuation }
        continuation.yield(current)
        return stream
    }

    // MARK: - Test Helpers

    func send(_ locale: AppLocale) {
        lock.withLock {
            $0.current = locale
            _ = $0.continuation?.yield(locale)
        }
    }
}
