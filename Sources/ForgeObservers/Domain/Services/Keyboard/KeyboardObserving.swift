/// Observes keyboard visibility and frame changes.
public protocol KeyboardObserving: Sendable {
    /// The current keyboard state. Thread-safe.
    var state: KeyboardState { get }

    /// Stream of keyboard state changes (show/hide with dimensions).
    var stateStream: AsyncStream<KeyboardState> { get }
}
