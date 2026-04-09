import Testing
import ForgeObservers

@Suite("NotificationPermission Helpers")
struct NotificationPermissionHelpersTests {

    // MARK: - isGranted

    @Test("isGranted returns true for authorized")
    func isGrantedAuthorized() {
        let mock = MockNotificationPermissionObserver(status: .authorized)
        #expect(mock.isGranted == true)
    }

    @Test("isGranted returns true for provisional")
    func isGrantedProvisional() {
        let mock = MockNotificationPermissionObserver(status: .provisional)
        #expect(mock.isGranted == true)
    }

    @Test("isGranted returns true for ephemeral")
    func isGrantedEphemeral() {
        let mock = MockNotificationPermissionObserver(status: .ephemeral)
        #expect(mock.isGranted == true)
    }

    @Test("isGranted returns false for notDetermined")
    func isGrantedNotDetermined() {
        let mock = MockNotificationPermissionObserver(status: .notDetermined)
        #expect(mock.isGranted == false)
    }

    @Test("isGranted returns false for denied")
    func isGrantedDenied() {
        let mock = MockNotificationPermissionObserver(status: .denied)
        #expect(mock.isGranted == false)
    }

    // MARK: - canRequestPermission

    @Test("canRequestPermission is true only for notDetermined")
    func canRequestPermissionNotDetermined() {
        let mock = MockNotificationPermissionObserver(status: .notDetermined)
        #expect(mock.canRequestPermission == true)
    }

    @Test("canRequestPermission is false for authorized")
    func canRequestPermissionAuthorized() {
        let mock = MockNotificationPermissionObserver(status: .authorized)
        #expect(mock.canRequestPermission == false)
    }

    @Test("canRequestPermission is false for denied")
    func canRequestPermissionDenied() {
        let mock = MockNotificationPermissionObserver(status: .denied)
        #expect(mock.canRequestPermission == false)
    }

    @Test("canRequestPermission is false for provisional")
    func canRequestPermissionProvisional() {
        let mock = MockNotificationPermissionObserver(status: .provisional)
        #expect(mock.canRequestPermission == false)
    }

    @Test("canRequestPermission is false for ephemeral")
    func canRequestPermissionEphemeral() {
        let mock = MockNotificationPermissionObserver(status: .ephemeral)
        #expect(mock.canRequestPermission == false)
    }

    // MARK: - isDenied

    @Test("isDenied is true only for denied")
    func isDeniedTrue() {
        let mock = MockNotificationPermissionObserver(status: .denied)
        #expect(mock.isDenied == true)
    }

    @Test("isDenied is false for notDetermined")
    func isDeniedNotDetermined() {
        let mock = MockNotificationPermissionObserver(status: .notDetermined)
        #expect(mock.isDenied == false)
    }

    @Test("isDenied is false for authorized")
    func isDeniedAuthorized() {
        let mock = MockNotificationPermissionObserver(status: .authorized)
        #expect(mock.isDenied == false)
    }

    @Test("isDenied is false for provisional")
    func isDeniedProvisional() {
        let mock = MockNotificationPermissionObserver(status: .provisional)
        #expect(mock.isDenied == false)
    }

    @Test("isDenied is false for ephemeral")
    func isDeniedEphemeral() {
        let mock = MockNotificationPermissionObserver(status: .ephemeral)
        #expect(mock.isDenied == false)
    }
}
