import ForgeObservers
import os

final class MockProtectedDataObserver: ProtectedDataObserving, Sendable {
    private struct LockedState: Sendable {
        var state: ProtectedDataState
        var continuation: AsyncStream<ProtectedDataState>.Continuation?
        var waitContinuation: CheckedContinuation<Void, Never>?
    }

    private let lock: OSAllocatedUnfairLock<LockedState>

    // MARK: - Initialization

    init(state: ProtectedDataState = .unavailable) {
        lock = OSAllocatedUnfairLock(initialState: LockedState(state: state))
    }

    // MARK: - Properties

    var state: ProtectedDataState {
        lock.withLock { $0.state }
    }

    // MARK: - Stream

    var stateStream: AsyncStream<ProtectedDataState> {
        let (stream, continuation) = AsyncStream.makeStream(of: ProtectedDataState.self)
        lock.withLock { $0.continuation = continuation }
        continuation.yield(state)
        return stream
    }

    // MARK: - Public

    func waitUntilAvailable() async {
        let shouldWait: Bool = lock.withLock { $0.state != .available }
        guard shouldWait else { return }

        await withCheckedContinuation { continuation in
            let alreadyAvailable = lock.withLock {
                if $0.state == .available {
                    return true
                }
                $0.waitContinuation = continuation
                return false
            }
            if alreadyAvailable {
                continuation.resume()
            }
        }
    }

    // MARK: - Test Helpers

    func send(_ state: ProtectedDataState) {
        lock.withLock {
            $0.state = state
            _ = $0.continuation?.yield(state)

            if state == .available, let waitContinuation = $0.waitContinuation {
                $0.waitContinuation = nil
                waitContinuation.resume()
            }
        }
    }
}
