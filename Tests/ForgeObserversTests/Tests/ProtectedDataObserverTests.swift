import Testing
import Foundation
import UIKit
@testable import ForgeObservers

/// Tests `ProtectedDataObserver` using an injected `NotificationCenter` and an explicit initial
/// state — avoids touching `UIApplication.shared.isProtectedDataAvailable` in the unit test environment.
@Suite("ProtectedDataObserver", .serialized)
struct ProtectedDataObserverTests {

    @Test("Honors injected initial state")
    @MainActor
    func initialStateRespected() {
        let center = NotificationCenter()
        let observer = ProtectedDataObserver(
            notificationCenter: center,
            initialState: .unavailable
        )
        #expect(observer.state == .unavailable)
    }

    @Test("Did become available notification updates state")
    @MainActor
    func didBecomeAvailable() async throws {
        let center = NotificationCenter()
        let observer = ProtectedDataObserver(
            notificationCenter: center,
            initialState: .unavailable
        )

        center.post(name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        try await Task.sleep(for: .milliseconds(50))

        #expect(observer.state == .available)
    }

    @Test("Will become unavailable notification updates state")
    @MainActor
    func willBecomeUnavailable() async throws {
        let center = NotificationCenter()
        let observer = ProtectedDataObserver(
            notificationCenter: center,
            initialState: .available
        )

        center.post(name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)
        try await Task.sleep(for: .milliseconds(50))

        #expect(observer.state == .unavailable)
    }

    @Test("stateStream emits the full transition sequence")
    @MainActor
    func streamEmitsTransitions() async throws {
        let center = NotificationCenter()
        let observer = ProtectedDataObserver(
            notificationCenter: center,
            initialState: .available
        )
        let collector = ProtectedDataCollector()

        let task = Task {
            for await state in observer.stateStream {
                await collector.append(state)
                if await collector.count >= 3 { break }
            }
        }

        try await Task.sleep(for: .milliseconds(50))
        center.post(name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)
        try await Task.sleep(for: .milliseconds(50))
        center.post(name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        try await Task.sleep(for: .milliseconds(50))

        await task.value

        let values = await collector.values
        #expect(values == [.available, .unavailable, .available])
    }

    @Test("waitUntilAvailable resumes when protected data becomes available")
    @MainActor
    func waitUntilAvailableResumes() async throws {
        let center = NotificationCenter()
        let observer = ProtectedDataObserver(
            notificationCenter: center,
            initialState: .unavailable
        )

        let waitTask = Task {
            await observer.waitUntilAvailable()
        }

        try await Task.sleep(for: .milliseconds(50))
        center.post(name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)

        // Should complete without hanging
        await waitTask.value
        #expect(observer.state == .available)
    }

    @Test("waitUntilAvailable returns immediately if already available")
    @MainActor
    func waitUntilAvailableImmediate() async {
        let center = NotificationCenter()
        let observer = ProtectedDataObserver(
            notificationCenter: center,
            initialState: .available
        )

        // Should return immediately — no notification needed.
        await observer.waitUntilAvailable()
        #expect(observer.state == .available)
    }
}

private actor ProtectedDataCollector {
    private(set) var values: [ProtectedDataState] = []
    var count: Int { values.count }
    func append(_ value: ProtectedDataState) { values.append(value) }
}

extension ProtectedDataState: Equatable {
    public static func == (lhs: ProtectedDataState, rhs: ProtectedDataState) -> Bool {
        switch (lhs, rhs) {
        case (.available, .available), (.unavailable, .unavailable): true
        default: false
        }
    }
}
