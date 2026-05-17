/// Observes application lifecycle transitions (active, inactive, background).
public protocol AppLifecycleObserving: Sendable {
    /// The current lifecycle state. Thread-safe.
    var state: AppLifecycleState { get }

    /// Stream of lifecycle state changes. Emits current value on subscription.
    var stateStream: AsyncStream<AppLifecycleState> { get }
}
