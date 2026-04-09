import ForgeObservers
import os

final class MockAppearanceObserver: AppearanceObserving, Sendable {
    private struct LockedState: Sendable {
        var current: AppAppearance
        var continuation: AsyncStream<AppAppearance>.Continuation?
    }

    private let lock: OSAllocatedUnfairLock<LockedState>

    // MARK: - Initialization

    init(current: AppAppearance = .light) {
        lock = OSAllocatedUnfairLock(initialState: LockedState(current: current))
    }

    // MARK: - Properties

    var current: AppAppearance {
        lock.withLock { $0.current }
    }

    // MARK: - Stream

    var appearanceStream: AsyncStream<AppAppearance> {
        let (stream, continuation) = AsyncStream.makeStream(of: AppAppearance.self)
        lock.withLock { $0.continuation = continuation }
        continuation.yield(current)
        return stream
    }

    // MARK: - Test Helpers

    func send(_ appearance: AppAppearance) {
        lock.withLock {
            $0.current = appearance
            _ = $0.continuation?.yield(appearance)
        }
    }
}
