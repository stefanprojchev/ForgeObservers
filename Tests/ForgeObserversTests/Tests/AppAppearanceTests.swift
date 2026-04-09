import Testing
import ForgeObservers

@Suite("AppAppearance")
struct AppAppearanceTests {

    // MARK: - Cases

    @Test("Light case exists")
    func lightCaseExists() {
        let appearance = AppAppearance.light
        #expect(appearance == .light)
    }

    @Test("Dark case exists")
    func darkCaseExists() {
        let appearance = AppAppearance.dark
        #expect(appearance == .dark)
    }

    @Test("Light and dark are distinct")
    func casesAreDistinct() {
        #expect(AppAppearance.light != .dark)
    }

    // MARK: - Sendable

    @Test("Conforms to Sendable")
    func conformsToSendable() {
        let appearance: any Sendable = AppAppearance.dark
        #expect(appearance is AppAppearance)
    }
}
