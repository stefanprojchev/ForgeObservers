import Testing
import Foundation
import UIKit
@testable import ForgeObservers

/// Tests `KeyboardObserver` using an injected `NotificationCenter` to pump fake
/// `UIResponder.keyboardWill{Show,Hide}` notifications with synthetic user info.
@Suite("KeyboardObserver", .serialized)
struct KeyboardObserverTests {

    @Test("Initial state is hidden")
    func initialState() {
        let center = NotificationCenter()
        let observer = KeyboardObserver(notificationCenter: center)
        #expect(observer.state.isVisible == false)
        #expect(observer.state.height == 0)
    }

    @Test("keyboardWillShow notification marks visible with parsed height")
    @MainActor
    func willShowUpdatesState() async throws {
        let center = NotificationCenter()
        let observer = KeyboardObserver(notificationCenter: center)

        let frame = CGRect(x: 0, y: 600, width: 390, height: 291)
        let userInfo: [AnyHashable: Any] = [
            UIResponder.keyboardFrameEndUserInfoKey: frame,
            UIResponder.keyboardAnimationDurationUserInfoKey: TimeInterval(0.3),
        ]
        center.post(
            name: UIResponder.keyboardWillShowNotification,
            object: nil,
            userInfo: userInfo
        )

        try await Task.sleep(for: .milliseconds(50))

        #expect(observer.state.isVisible == true)
        #expect(observer.state.height == 291)
        #expect(observer.state.animationDuration == 0.3)
    }

    @Test("keyboardWillHide notification resets state")
    @MainActor
    func willHideResetsState() async throws {
        let center = NotificationCenter()
        let observer = KeyboardObserver(notificationCenter: center)

        // Show first
        center.post(
            name: UIResponder.keyboardWillShowNotification,
            object: nil,
            userInfo: [
                UIResponder.keyboardFrameEndUserInfoKey: CGRect(x: 0, y: 0, width: 100, height: 300),
                UIResponder.keyboardAnimationDurationUserInfoKey: TimeInterval(0.25),
            ]
        )
        try await Task.sleep(for: .milliseconds(50))
        #expect(observer.state.isVisible == true)

        // Then hide
        center.post(
            name: UIResponder.keyboardWillHideNotification,
            object: nil,
            userInfo: [
                UIResponder.keyboardAnimationDurationUserInfoKey: TimeInterval(0.25),
            ]
        )
        try await Task.sleep(for: .milliseconds(50))

        #expect(observer.state.isVisible == false)
        #expect(observer.state.height == 0)
    }

    @Test("stateStream emits show-then-hide sequence")
    @MainActor
    func streamEmitsTransitions() async throws {
        let center = NotificationCenter()
        let observer = KeyboardObserver(notificationCenter: center)
        let collector = KeyboardCollector()

        let task = Task {
            for await state in observer.stateStream {
                await collector.append(state.isVisible)
                if await collector.count >= 3 { break }
            }
        }

        try await Task.sleep(for: .milliseconds(50))

        center.post(
            name: UIResponder.keyboardWillShowNotification,
            object: nil,
            userInfo: [
                UIResponder.keyboardFrameEndUserInfoKey: CGRect(x: 0, y: 0, width: 100, height: 250),
                UIResponder.keyboardAnimationDurationUserInfoKey: TimeInterval(0.25),
            ]
        )
        try await Task.sleep(for: .milliseconds(50))

        center.post(
            name: UIResponder.keyboardWillHideNotification,
            object: nil,
            userInfo: [UIResponder.keyboardAnimationDurationUserInfoKey: TimeInterval(0.25)]
        )
        try await Task.sleep(for: .milliseconds(50))

        await task.value

        let values = await collector.values
        #expect(values == [false, true, false])
    }

    @Test("Missing frame defaults to .zero height")
    @MainActor
    func missingFrameDefaults() async throws {
        let center = NotificationCenter()
        let observer = KeyboardObserver(notificationCenter: center)

        center.post(
            name: UIResponder.keyboardWillShowNotification,
            object: nil,
            userInfo: nil
        )
        try await Task.sleep(for: .milliseconds(50))

        #expect(observer.state.isVisible == true)
        #expect(observer.state.height == 0)
        // Default animation duration is 0.25
        #expect(observer.state.animationDuration == 0.25)
    }
}

private actor KeyboardCollector {
    private(set) var values: [Bool] = []
    var count: Int { values.count }
    func append(_ value: Bool) { values.append(value) }
}
