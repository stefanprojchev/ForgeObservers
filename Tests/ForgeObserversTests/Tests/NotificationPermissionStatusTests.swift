import Testing
import ForgeObservers

@Suite("NotificationPermissionStatus")
struct NotificationPermissionStatusTests {

    // MARK: - Cases

    @Test("notDetermined case exists")
    func notDeterminedCaseExists() {
        let status = NotificationPermissionStatus.notDetermined
        #expect(status == .notDetermined)
    }

    @Test("authorized case exists")
    func authorizedCaseExists() {
        let status = NotificationPermissionStatus.authorized
        #expect(status == .authorized)
    }

    @Test("denied case exists")
    func deniedCaseExists() {
        let status = NotificationPermissionStatus.denied
        #expect(status == .denied)
    }

    @Test("provisional case exists")
    func provisionalCaseExists() {
        let status = NotificationPermissionStatus.provisional
        #expect(status == .provisional)
    }

    @Test("ephemeral case exists")
    func ephemeralCaseExists() {
        let status = NotificationPermissionStatus.ephemeral
        #expect(status == .ephemeral)
    }

    @Test("All five cases are distinct")
    func allCasesAreDistinct() {
        let cases: [NotificationPermissionStatus] = [
            .notDetermined, .authorized, .denied, .provisional, .ephemeral
        ]
        for i in cases.indices {
            for j in cases.indices where i != j {
                #expect(cases[i] != cases[j])
            }
        }
    }

    // MARK: - Sendable

    @Test("Conforms to Sendable")
    func conformsToSendable() {
        let status: any Sendable = NotificationPermissionStatus.authorized
        #expect(status is NotificationPermissionStatus)
    }
}
