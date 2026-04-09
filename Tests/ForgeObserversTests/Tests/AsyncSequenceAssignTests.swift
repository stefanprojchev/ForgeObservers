import Testing
@testable import ForgeObservers

@MainActor
@Suite("AsyncSequence+Assign")
struct AsyncSequenceAssignTests {
    private static let wifi = ConnectivityStatus(
        isConnected: true,
        interface: .wifi,
        isExpensive: false,
        isConstrained: false
    )

    // MARK: - Assign

    @Test("assign(to:on:) assigns values from stream")
    func assignDirectly() async {
        let mock = MockConnectivityObserver(status: .disconnected)
        let target = TestTarget()

        let task = Task { @MainActor in
            await mock.statusStream.assign(to: \.status, on: target)
        }

        for _ in 0..<100 {
            await Task.yield()
            if target.status == .disconnected { break }
        }
        #expect(target.status == .disconnected)

        mock.send(Self.wifi)
        for _ in 0..<100 {
            await Task.yield()
            if target.status == Self.wifi { break }
        }
        #expect(target.status == Self.wifi)

        task.cancel()
    }

    // MARK: - Transform

    @Test("assign(to:on:transform:) transforms and assigns values")
    func assignWithTransform() async {
        let mock = MockConnectivityObserver(status: Self.wifi)
        let target = TestTarget()

        let task = Task { @MainActor in
            await mock.statusStream
                .assign(to: \.isOffline, on: target, transform: { !$0.isConnected })
        }

        for _ in 0..<100 {
            await Task.yield()
            if target.isOffline == false { break }
        }
        #expect(target.isOffline == false)

        mock.send(.disconnected)
        for _ in 0..<100 {
            await Task.yield()
            if target.isOffline == true { break }
        }
        #expect(target.isOffline == true)

        task.cancel()
    }
}

// MARK: - Helpers

@MainActor
private final class TestTarget {
    var status: ConnectivityStatus = .disconnected
    var isOffline: Bool = false
}
