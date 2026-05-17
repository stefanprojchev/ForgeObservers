import Foundation
import Network
import os

/// Monitors network connectivity via `NWPathMonitor`.
public final class ConnectivityObserver: ConnectivityObserving, Sendable {

    // MARK: - Dependencies

    private struct LockedState: Sendable {
        var status: ConnectivityStatus = .disconnected
        var continuations: [UUID: AsyncStream<ConnectivityStatus>.Continuation] = [:]
    }

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "forge.connectivity.monitor")
    private let lock = OSAllocatedUnfairLock(initialState: LockedState())

    // MARK: - Init

    /// Creates the observer and begins monitoring network path changes.
    public init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let status = ConnectivityStatus(from: path)

            let continuations = self.lock.withLock { state -> [AsyncStream<ConnectivityStatus>.Continuation] in
                state.status = status
                return Array(state.continuations.values)
            }

            for continuation in continuations {
                continuation.yield(status)
            }
        }
        monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
        let continuations = lock.withLock { Array($0.continuations.values) }
        for continuation in continuations {
            continuation.finish()
        }
    }

    // MARK: - Implementation

    public var status: ConnectivityStatus {
        lock.withLock { $0.status }
    }

    public var statusStream: AsyncStream<ConnectivityStatus> {
        let id = UUID()
        return AsyncStream { continuation in
            continuation.onTermination = { [weak self] _ in
                self?.lock.withLock { $0.continuations[id] = nil }
            }

            let current = self.lock.withLock { state -> ConnectivityStatus in
                state.continuations[id] = continuation
                return state.status
            }
            continuation.yield(current)
        }
    }
}
