/// Observes system appearance changes (light/dark mode).
public protocol AppearanceObserving: Sendable {
    /// The current system appearance. Thread-safe.
    var current: AppAppearance { get }

    /// Stream of appearance changes. Emits current value on subscription.
    var appearanceStream: AsyncStream<AppAppearance> { get }
}
