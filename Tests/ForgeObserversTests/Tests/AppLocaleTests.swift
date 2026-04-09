import Testing
import Foundation
import ForgeObservers

@Suite("AppLocale")
struct AppLocaleTests {

    // MARK: - Initialization

    @Test("Default init reads from Locale.current")
    func defaultInitReadsFromCurrent() {
        let appLocale = AppLocale()
        let expected = Locale.current.language.languageCode?.identifier ?? "en"
        #expect(appLocale.languageCode == expected)
    }

    @Test("Language code has a value")
    func languageCodeHasValue() {
        let appLocale = AppLocale()
        #expect(!appLocale.languageCode.isEmpty)
    }

    @Test("Custom locale init extracts correct language code")
    func customLocaleInit() {
        let locale = Locale(identifier: "mk_MK")
        let appLocale = AppLocale(from: locale)
        #expect(appLocale.languageCode == "mk")
    }

    @Test("Custom locale init extracts region code")
    func customLocaleInitRegion() {
        let locale = Locale(identifier: "en_GB")
        let appLocale = AppLocale(from: locale)
        #expect(appLocale.regionCode == "GB")
    }

    // MARK: - Equatable

    @Test("Equatable conformance - same locale produces equal instances")
    func equatableSameLocale() {
        let locale = Locale(identifier: "en_US")
        let a = AppLocale(from: locale)
        let b = AppLocale(from: locale)
        #expect(a == b)
    }

    @Test("Different locales produce different instances")
    func differentLocalesAreNotEqual() {
        let en = AppLocale(from: Locale(identifier: "en_US"))
        let mk = AppLocale(from: Locale(identifier: "mk_MK"))
        #expect(en != mk)
    }

    // MARK: - Sendable

    @Test("Conforms to Sendable")
    func conformsToSendable() {
        let locale: any Sendable = AppLocale()
        #expect(locale is AppLocale)
    }
}
