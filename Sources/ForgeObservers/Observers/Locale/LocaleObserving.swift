/// Observes locale changes (language, region) from device settings.
public protocol LocaleObserving: Sendable {
    /// The current locale snapshot. Thread-safe.
    var current: AppLocale { get }

    /// Stream of locale changes. Emits current value on subscription.
    var localeStream: AsyncStream<AppLocale> { get }
}
