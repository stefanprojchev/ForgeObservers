/// Observes network reachability and connection type.
public protocol ConnectivityObserving: Sendable {
    /// The current connectivity status. Thread-safe.
    var status: ConnectivityStatus { get }

    /// Stream of connectivity changes. Emits current value on subscription.
    var statusStream: AsyncStream<ConnectivityStatus> { get }
}
