import Testing
import ForgeObservers

@Suite("ProtectedDataState")
struct ProtectedDataStateTests {

    // MARK: - Cases

    @Test("Available case exists")
    func availableCaseExists() {
        let state = ProtectedDataState.available
        #expect(state == .available)
    }

    @Test("Unavailable case exists")
    func unavailableCaseExists() {
        let state = ProtectedDataState.unavailable
        #expect(state == .unavailable)
    }

    @Test("Available and unavailable are distinct")
    func casesAreDistinct() {
        #expect(ProtectedDataState.available != .unavailable)
    }

    // MARK: - Sendable

    @Test("Conforms to Sendable")
    func conformsToSendable() {
        let state: any Sendable = ProtectedDataState.available
        #expect(state is ProtectedDataState)
    }
}
