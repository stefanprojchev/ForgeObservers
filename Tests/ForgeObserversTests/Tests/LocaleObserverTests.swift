import Testing
import Foundation
import Synchronization
@testable import ForgeObservers

/// Tests `LocaleObserver` using an injected `NotificationCenter` and `localeProvider` closure.
/// The closure lets us simulate locale changes without touching the real system locale.
@Suite("LocaleObserver", .serialized)
struct LocaleObserverTests {

    @Test("Initial locale comes from the injected provider")
    func initialLocaleFromProvider() {
        let center = NotificationCenter()
        let stub = AppLocale(languageCode: "en", regionCode: "US")

        let observer = LocaleObserver(
            notificationCenter: center,
            localeProvider: { stub }
        )

        #expect(observer.current == stub)
    }

    @Test("Locale change notification updates current locale")
    func localeChangeUpdates() async throws {
        let center = NotificationCenter()

        let current = Mutex<AppLocale>(AppLocale(languageCode: "en", regionCode: "US"))

        let observer = LocaleObserver(
            notificationCenter: center,
            localeProvider: { current.withLock { $0 } }
        )

        // Swap the locale and post the change notification
        current.withLock { $0 = AppLocale(languageCode: "de", regionCode: "DE") }
        center.post(name: NSLocale.currentLocaleDidChangeNotification, object: nil)

        try await Task.sleep(for: .milliseconds(50))

        #expect(observer.current.languageCode == "de")
        #expect(observer.current.regionCode == "DE")
    }

    @Test("Identical locale updates do not emit duplicate stream values")
    func skipsIdenticalUpdates() async throws {
        let center = NotificationCenter()
        let fixed = AppLocale(languageCode: "en", regionCode: "US")

        let observer = LocaleObserver(
            notificationCenter: center,
            localeProvider: { fixed }
        )

        let collector = LocaleCollector()

        let task = Task {
            for await locale in observer.localeStream {
                await collector.append(locale.languageCode)
                if await collector.count >= 1 { break }
            }
        }

        try await Task.sleep(for: .milliseconds(50))

        // Multiple notifications with identical locales → only the initial yield should appear.
        center.post(name: NSLocale.currentLocaleDidChangeNotification, object: nil)
        center.post(name: NSLocale.currentLocaleDidChangeNotification, object: nil)
        center.post(name: NSLocale.currentLocaleDidChangeNotification, object: nil)

        try await Task.sleep(for: .milliseconds(50))

        await task.value

        let values = await collector.values
        #expect(values == ["en"])
    }
}

private actor LocaleCollector {
    private(set) var values: [String] = []
    var count: Int { values.count }
    func append(_ value: String) { values.append(value) }
}
