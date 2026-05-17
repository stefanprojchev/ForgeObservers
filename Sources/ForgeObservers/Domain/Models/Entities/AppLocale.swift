import Foundation

/// A `Sendable` snapshot of the current locale.
public struct AppLocale: Sendable, Equatable {
    /// BCP 47 language code (e.g., "en", "mk").
    public let languageCode: String

    /// Region code, if available (e.g., "US", "MK").
    public let regionCode: String?

    public init(languageCode: String, regionCode: String? = nil) {
        self.languageCode = languageCode
        self.regionCode = regionCode
    }

    public init(from locale: Locale = .current) {
        languageCode = locale.language.languageCode?.identifier ?? "en"
        regionCode = locale.region?.identifier
    }
}
