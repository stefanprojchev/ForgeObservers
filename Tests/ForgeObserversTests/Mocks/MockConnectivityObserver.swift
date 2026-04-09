import ForgeObservers
import os

final class MockConnectivityObserver: ConnectivityObserving, Sendable {
    private struct LockedState: Sendable {
        var status: ConnectivityStatus
        var continuation: AsyncStream<ConnectivityStatus>.Continuation?
    }

    private let lock: OSAllocatedUnfairLock<LockedState>

    // MARK: - Initialization

    init(status: ConnectivityStatus = .disconnected) {
        lock = OSAllocatedUnfairLock(initialState: LockedState(status: status))
    }

    // MARK: - Properties

    var status: ConnectivityStatus {
        lock.withLock { $0.status }
    }

    // MARK: - Stream

    var statusStream: AsyncStream<ConnectivityStatus> {
        let (stream, continuation) = AsyncStream.makeStream(of: ConnectivityStatus.self)
        lock.withLock { $0.continuation = continuation }
        continuation.yield(status)
        return stream
    }

    // MARK: - Test Helpers

    func send(_ status: ConnectivityStatus) {
        lock.withLock {
            $0.status = status
            _ = $0.continuation?.yield(status)
        }
    }
}
