import ForgeObservers
import os

final class MockKeyboardObserver: KeyboardObserving, Sendable {
    private struct LockedState: Sendable {
        var state: KeyboardState
        var continuation: AsyncStream<KeyboardState>.Continuation?
    }

    private let lock: OSAllocatedUnfairLock<LockedState>

    // MARK: - Initialization

    init(state: KeyboardState = .hidden) {
        lock = OSAllocatedUnfairLock(initialState: LockedState(state: state))
    }

    // MARK: - Properties

    var state: KeyboardState {
        lock.withLock { $0.state }
    }

    // MARK: - Stream

    var stateStream: AsyncStream<KeyboardState> {
        let (stream, continuation) = AsyncStream.makeStream(of: KeyboardState.self)
        lock.withLock { $0.continuation = continuation }
        continuation.yield(state)
        return stream
    }

    // MARK: - Test Helpers

    func send(_ state: KeyboardState) {
        lock.withLock {
            $0.state = state
            _ = $0.continuation?.yield(state)
        }
    }
}
