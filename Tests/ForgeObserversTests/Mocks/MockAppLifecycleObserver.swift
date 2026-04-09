import ForgeObservers
import os

final class MockAppLifecycleObserver: AppLifecycleObserving, Sendable {
    private struct LockedState: Sendable {
        var state: AppLifecycleState
        var continuation: AsyncStream<AppLifecycleState>.Continuation?
    }

    private let lock: OSAllocatedUnfairLock<LockedState>

    // MARK: - Initialization

    init(state: AppLifecycleState = .background) {
        lock = OSAllocatedUnfairLock(initialState: LockedState(state: state))
    }

    // MARK: - Properties

    var state: AppLifecycleState {
        lock.withLock { $0.state }
    }

    // MARK: - Stream

    var stateStream: AsyncStream<AppLifecycleState> {
        let (stream, continuation) = AsyncStream.makeStream(of: AppLifecycleState.self)
        lock.withLock { $0.continuation = continuation }
        continuation.yield(state)
        return stream
    }

    // MARK: - Test Helpers

    func send(_ state: AppLifecycleState) {
        lock.withLock {
            $0.state = state
            _ = $0.continuation?.yield(state)
        }
    }
}
