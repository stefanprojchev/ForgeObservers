import Testing
import ForgeObservers

@Suite("ConnectivityStatus")
struct ConnectivityStatusTests {

    // MARK: - Defaults

    @Test("Disconnected static has correct defaults")
    func disconnectedDefaults() {
        let status = ConnectivityStatus.disconnected
        #expect(status.isConnected == false)
        #expect(status.interface == .none)
        #expect(status.isExpensive == false)
        #expect(status.isConstrained == false)
    }

    // MARK: - Initialization

    @Test("Custom initialization stores values correctly")
    func customInit() {
        let status = ConnectivityStatus(
            isConnected: true,
            interface: .wifi,
            isExpensive: false,
            isConstrained: true
        )
        #expect(status.isConnected == true)
        #expect(status.interface == .wifi)
        #expect(status.isExpensive == false)
        #expect(status.isConstrained == true)
    }

    // MARK: - Equatable

    @Test("Equal instances are equal")
    func equalInstances() {
        let a = ConnectivityStatus(isConnected: true, interface: .cellular, isExpensive: true, isConstrained: false)
        let b = ConnectivityStatus(isConnected: true, interface: .cellular, isExpensive: true, isConstrained: false)
        #expect(a == b)
    }

    @Test("Different instances are not equal")
    func differentInstances() {
        let wifi = ConnectivityStatus(isConnected: true, interface: .wifi, isExpensive: false, isConstrained: false)
        let cellular = ConnectivityStatus(isConnected: true, interface: .cellular, isExpensive: true, isConstrained: false)
        #expect(wifi != cellular)
    }

    // MARK: - ConnectionInterface

    @Test("All interface cases exist")
    func interfaceCases() {
        let cases: [ConnectionInterface] = [.wifi, .cellular, .wiredEthernet, .other, .none]
        #expect(cases.count == 5)
    }

    // MARK: - Sendable

    @Test("Conforms to Sendable")
    func conformsToSendable() {
        let status = ConnectivityStatus.disconnected
        let sendable: any Sendable = status
        #expect(sendable is ConnectivityStatus)
    }
}
