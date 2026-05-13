# ForgeObservers

Reactive system observers for iOS — connectivity, lifecycle, keyboard, and more.

![Swift 6.3+](https://img.shields.io/badge/Swift-6.3+-orange.svg)
![iOS 18+](https://img.shields.io/badge/iOS-18+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)
[![Release](https://img.shields.io/github/v/release/stefanprojchev/ForgeObservers)](https://github.com/stefanprojchev/ForgeObservers/releases)

---

ForgeObservers exposes the most common iOS system events as `AsyncStream` values behind clean protocols. Every observer is testable via an injectable `NotificationCenter` — no `UIApplication.shared` required, no `@testable import` tricks.

## Observers

| Observer | Protocol | Emits |
|---|---|---|
| **ConnectivityObserver** | `ConnectivityObserving` | `ConnectivityStatus` — network path, interface, expensive/constrained flags |
| **AppLifecycleObserver** | `AppLifecycleObserving` | `AppLifecycleState` — `.active`, `.inactive`, `.background` |
| **KeyboardObserver** | `KeyboardObserving` | `KeyboardState` — visibility, height, animation duration |
| **AppearanceObserver** | `AppearanceObserving` | `AppAppearance` — light/dark mode |
| **LocaleObserver** | `LocaleObserving` | `AppLocale` — language + region code |
| **ProtectedDataObserver** | `ProtectedDataObserving` | `ProtectedDataState` — available/unavailable, with `waitUntilAvailable()` |
| **NotificationPermissionObserver** | `NotificationPermissionObserving` | `NotificationPermissionStatus` |

## Features

- **AsyncStream-first** — subscribe with `for await` in a `.task` modifier or inside an actor
- **Protocol-oriented** — each observer has a protocol, making mocking trivial
- **Testable by design** — notification-based observers accept an injectable `NotificationCenter` so tests can pump fake notifications
- **`.assign(to:on:)` helper** — bind any `AsyncSequence` directly to a property on an object
- **Zero Combine dependency** — pure Swift Concurrency

## Requirements

- **iOS** 18+
- **Swift** 6.3+ (Xcode 26 or later)

## Installation

### Xcode

1. **File → Add Package Dependencies…**
2. Paste `https://github.com/stefanprojchev/ForgeObservers.git`
3. Set rule to **Up to Next Major** from `1.0.0`

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/stefanprojchev/ForgeObservers.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["ForgeObservers"]
    )
]
```

## Quick Start

### Connectivity

```swift
import ForgeObservers

let connectivity = ConnectivityObserver()

// Sync read of the current status
if connectivity.status.isConnected {
    await fetchLatestData()
}

// Subscribe to changes
Task {
    for await status in connectivity.statusStream {
        print("Connected: \(status.isConnected), via: \(status.interface)")
    }
}
```

### App Lifecycle in SwiftUI

```swift
import SwiftUI
import ForgeObservers

struct ContentView: View {
    let lifecycle: AppLifecycleObserving

    var body: some View {
        FeedView()
            .task {
                for await state in lifecycle.stateStream {
                    switch state {
                    case .active:     resumeTimers()
                    case .background: await saveState()
                    case .inactive:   break
                    }
                }
            }
    }
}
```

### Testing with injected NotificationCenter

```swift
import Testing
import UIKit
@testable import ForgeObservers

@Test
func lifecycleReactsToBackground() async throws {
    // Inject a fresh NotificationCenter — no interference from the real one
    let center = NotificationCenter()
    let observer = AppLifecycleObserver(notificationCenter: center)

    center.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
    try await Task.sleep(for: .milliseconds(50))

    #expect(observer.state == .background)
}
```

## AsyncSequence helpers

Bind any stream directly to a property:

```swift
@Observable
final class AppViewModel {
    var isOffline = false

    func start(connectivity: ConnectivityObserving) async {
        await connectivity.statusStream
            .map { !$0.isConnected }
            .assign(to: \.isOffline, on: self)
    }
}
```

## The Forge Family

ForgeObservers is part of the **Forge** family of Swift packages for iOS.

| Package | Description |
|---|---|
| [ForgeCore](https://github.com/stefanprojchev/ForgeCore) | Thread-safe primitives for iOS Swift packages. |
| [ForgeInject](https://github.com/stefanprojchev/ForgeInject) | Dependency injection with constructor and property wrapper support. |
| **ForgeObservers** | Reactive system observers — connectivity, lifecycle, keyboard, and more. |
| [ForgeStorage](https://github.com/stefanprojchev/ForgeStorage) | Type-safe key-value, file, and Keychain storage. |
| [ForgeDB](https://github.com/stefanprojchev/ForgeDB) | Type-safe repository pattern and GRDB-backed SQLite persistence. |
| [ForgeOrchestrator](https://github.com/stefanprojchev/ForgeOrchestrator) | Orchestrate app flows — startup gates, data pipelines, and continuous monitors. |
| [ForgePush](https://github.com/stefanprojchev/ForgePush) | Push notification management — permissions, tokens, and routing. |
| [ForgeLocation](https://github.com/stefanprojchev/ForgeLocation) | Location triggers — geofencing, significant changes, and visits. |
| [ForgeBackgroundTasks](https://github.com/stefanprojchev/ForgeBackgroundTasks) | Background task scheduling and dispatch. |

## License

ForgeObservers is released under the MIT License. See [LICENSE](LICENSE).
