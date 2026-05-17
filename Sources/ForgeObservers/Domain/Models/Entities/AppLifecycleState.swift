/// The application's current lifecycle state.
public enum AppLifecycleState: Sendable {
    /// The app is in the foreground and receiving events.
    case active

    /// The app is in the foreground but not receiving events (e.g., incoming call).
    case inactive

    /// The app is in the background.
    case background
}
