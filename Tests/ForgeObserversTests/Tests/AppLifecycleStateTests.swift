import Testing
import ForgeObservers

@Suite("AppLifecycleState")
struct AppLifecycleStateTests {

    // MARK: - Cases

    @Test("Active case exists")
    func activeCaseExists() {
        let state = AppLifecycleState.active
        #expect(state == .active)
    }

    @Test("Inactive case exists")
    func inactiveCaseExists() {
        let state = AppLifecycleState.inactive
        #expect(state == .inactive)
    }

    @Test("Background case exists")
    func backgroundCaseExists() {
        let state = AppLifecycleState.background
        #expect(state == .background)
    }

    @Test("All three cases are distinct")
    func allCasesAreDistinct() {
        let cases: [AppLifecycleState] = [.active, .inactive, .background]
        for i in cases.indices {
            for j in cases.indices where i != j {
                #expect(cases[i] != cases[j])
            }
        }
    }

    // MARK: - Sendable

    @Test("Conforms to Sendable")
    func conformsToSendable() {
        let state: AppLifecycleState = .active
        let sendable: any Sendable = state
        #expect(sendable is AppLifecycleState)
    }
}
