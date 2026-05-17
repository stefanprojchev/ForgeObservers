import UIKit

/// The keyboard's current visibility and dimensions.
public struct KeyboardState: Sendable, Equatable {
    /// Whether the keyboard is currently visible.
    public let isVisible: Bool

    /// The height of the keyboard in points. Zero when hidden.
    public let height: CGFloat

    /// The system animation duration for the keyboard transition.
    public let animationDuration: TimeInterval

    public init(isVisible: Bool, height: CGFloat, animationDuration: TimeInterval) {
        self.isVisible = isVisible
        self.height = height
        self.animationDuration = animationDuration
    }

    /// Default hidden state.
    public static let hidden = KeyboardState(
        isVisible: false,
        height: 0,
        animationDuration: 0.25
    )
}
