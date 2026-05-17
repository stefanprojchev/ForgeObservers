/// The active network interface type.
public enum ConnectionInterface: Sendable, Equatable {
    case wifi
    case cellular
    case wiredEthernet
    case other
    case none
}
