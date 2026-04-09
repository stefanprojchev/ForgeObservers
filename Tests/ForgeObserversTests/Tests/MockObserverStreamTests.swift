import Testing
import ForgeObservers

@Suite("Mock Observer Streams")
struct MockObserverStreamTests {
    private static let wifi = ConnectivityStatus(
        isConnected: true,
        interface: .wifi,
        isExpensive: false,
        isConstrained: false
    )

    // MARK: - Initial Value

    @Test("MockConnectivityObserver emits initial value on stream subscription")
    func connectivityEmitsInitialValue() async {
        let mock = MockConnectivityObserver(status: Self.wifi)
        var iterator = mock.statusStream.makeAsyncIterator()
        let first = await iterator.next()
        #expect(first == Self.wifi)
    }

    @Test("MockAppLifecycleObserver emits initial value on stream subscription")
    func lifecycleEmitsInitialValue() async {
        let mock = MockAppLifecycleObserver(state: .active)
        var iterator = mock.stateStream.makeAsyncIterator()
        let first = await iterator.next()
        #expect(first == .active)
    }

    @Test("MockAppearanceObserver emits initial value on stream subscription")
    func appearanceEmitsInitialValue() async {
        let mock = MockAppearanceObserver(current: .dark)
        var iterator = mock.appearanceStream.makeAsyncIterator()
        let first = await iterator.next()
        #expect(first == .dark)
    }

    @Test("MockNotificationPermissionObserver emits initial value on stream subscription")
    func notificationPermissionEmitsInitialValue() async {
        let mock = MockNotificationPermissionObserver(status: .authorized)
        var iterator = mock.statusStream.makeAsyncIterator()
        let first = await iterator.next()
        #expect(first == .authorized)
    }

    // MARK: - Send Updates

    @Test("MockConnectivityObserver send updates property and stream")
    func connectivitySendUpdates() async {
        let mock = MockConnectivityObserver(status: .disconnected)
        var iterator = mock.statusStream.makeAsyncIterator()

        let initial = await iterator.next()
        #expect(initial == .disconnected)

        mock.send(Self.wifi)

        #expect(mock.status == Self.wifi)

        let next = await iterator.next()
        #expect(next == Self.wifi)
    }

    @Test("MockAppLifecycleObserver send updates property and stream")
    func lifecycleSendUpdates() async {
        let mock = MockAppLifecycleObserver(state: .background)
        var iterator = mock.stateStream.makeAsyncIterator()

        let initial = await iterator.next()
        #expect(initial == .background)

        mock.send(.active)

        #expect(mock.state == .active)

        let next = await iterator.next()
        #expect(next == .active)
    }

    @Test("MockAppearanceObserver send updates property and stream")
    func appearanceSendUpdates() async {
        let mock = MockAppearanceObserver(current: .light)
        var iterator = mock.appearanceStream.makeAsyncIterator()

        let initial = await iterator.next()
        #expect(initial == .light)

        mock.send(.dark)

        #expect(mock.current == .dark)

        let next = await iterator.next()
        #expect(next == .dark)
    }

    @Test("MockNotificationPermissionObserver send updates property and stream")
    func notificationPermissionSendUpdates() async {
        let mock = MockNotificationPermissionObserver(status: .notDetermined)
        var iterator = mock.statusStream.makeAsyncIterator()

        let initial = await iterator.next()
        #expect(initial == .notDetermined)

        mock.send(.denied)

        #expect(mock.status == .denied)

        let next = await iterator.next()
        #expect(next == .denied)
    }
}
