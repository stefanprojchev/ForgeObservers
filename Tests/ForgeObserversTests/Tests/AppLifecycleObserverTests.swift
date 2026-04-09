import Testing
import Foundation
import UIKit
@testable import ForgeObservers

/// Tests `AppLifecycleObserver` using an injected `NotificationCenter` to pump
/// fake `UIApplication` lifecycle notifications deterministically.
@Suite("AppLifecycleObserver", .serialized)
struct AppLifecycleObserverTests {

    @Test("Initial state is active")
    func initialState() {
        let center = NotificationCenter()
        let observer = AppLifecycleObserver(notificationCenter: center)
        #expect(observer.state == .active)
    }

    @Test("didBecomeActive notification updates state to active")
    @MainActor
    func didBecomeActiveUpdatesState() async throws {
        let center = NotificationCenter()
        let observer = AppLifecycleObserver(notificationCenter: center)

        // Start from non-active
        center.post(name: UIApplication.willResignActiveNotification, object: nil)
        try await Task.sleep(for: .milliseconds(50))
        #expect(observer.state == .inactive)

        center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        try await Task.sleep(for: .milliseconds(50))
        #expect(observer.state == .active)
    }

    @Test("willResignActive notification updates state to inactive")
    @MainActor
    func willResignActiveUpdatesState() async throws {
        let center = NotificationCenter()
        let observer = AppLifecycleObserver(notificationCenter: center)

        center.post(name: UIApplication.willResignActiveNotification, object: nil)
        try await Task.sleep(for: .milliseconds(50))
        #expect(observer.state == .inactive)
    }

    @Test("didEnterBackground notification updates state to background")
    @MainActor
    func didEnterBackgroundUpdatesState() async throws {
        let center = NotificationCenter()
        let observer = AppLifecycleObserver(notificationCenter: center)

        center.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        try await Task.sleep(for: .milliseconds(50))
        #expect(observer.state == .background)
    }

    @Test("stateStream emits the full transition sequence")
    @MainActor
    func streamEmitsTransitions() async throws {
        let center = NotificationCenter()
        let observer = AppLifecycleObserver(notificationCenter: center)
        let collector = LifecycleCollector()

        let task = Task {
            for await state in observer.stateStream {
                await collector.append(state)
                if await collector.count >= 4 { break }
            }
        }

        try await Task.sleep(for: .milliseconds(50))
        center.post(name: UIApplication.willResignActiveNotification, object: nil)
        try await Task.sleep(for: .milliseconds(50))
        center.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        try await Task.sleep(for: .milliseconds(50))
        center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        try await Task.sleep(for: .milliseconds(50))

        await task.value

        let values = await collector.values
        #expect(values == [.active, .inactive, .background, .active])
    }
}

private actor LifecycleCollector {
    private(set) var values: [AppLifecycleState] = []
    var count: Int { values.count }
    func append(_ value: AppLifecycleState) { values.append(value) }
}
