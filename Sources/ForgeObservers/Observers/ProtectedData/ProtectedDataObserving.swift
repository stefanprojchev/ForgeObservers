/// Observes whether iOS-protected data (Keychain, Core Data, encrypted files) is accessible.
public protocol ProtectedDataObserving: Sendable {
    /// The current protected data state. Thread-safe.
    var state: ProtectedDataState { get }

    /// Stream of protected data availability changes.
    var stateStream: AsyncStream<ProtectedDataState> { get }

    /// Suspends until protected data becomes available. Returns immediately if already available.
    func waitUntilAvailable() async
}
