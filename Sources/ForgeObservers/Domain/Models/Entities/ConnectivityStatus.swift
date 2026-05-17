import Network

/// A snapshot of the device's current network connectivity.
public struct ConnectivityStatus: Sendable, Equatable {
    /// Whether the device has a usable network path.
    public let isConnected: Bool

    /// The primary network interface in use.
    public let interface: ConnectionInterface

    /// `true` when on cellular or personal hotspot — gate large downloads.
    public let isExpensive: Bool

    /// `true` when Low Data Mode is enabled — reduce media quality.
    public let isConstrained: Bool

    public init(
        isConnected: Bool,
        interface: ConnectionInterface,
        isExpensive: Bool,
        isConstrained: Bool
    ) {
        self.isConnected = isConnected
        self.interface = interface
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
    }

    /// Default disconnected state.
    public static let disconnected = ConnectivityStatus(
        isConnected: false,
        interface: .none,
        isExpensive: false,
        isConstrained: false
    )
}

extension ConnectivityStatus {
    init(from path: NWPath) {
        isConnected = path.status == .satisfied
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained

        if path.usesInterfaceType(.wifi) {
            interface = .wifi
        } else if path.usesInterfaceType(.cellular) {
            interface = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            interface = .wiredEthernet
        } else if path.status == .satisfied {
            interface = .other
        } else {
            interface = .none
        }
    }
}
