# ForgeObservers

Reactive system observers for iOS, built with Swift.

## Requirements

- iOS 16+
- Swift 6.0+

## Installation

### Swift Package Manager

Add ForgeObservers to your project via Xcode:

1. **File > Add Package Dependencies...**
2. Enter the repository URL
3. Select the version rule and add to your target

Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/stefanprojchev/ForgeObservers.git", from: "1.0.0")
]
```

## Quick Start

```swift
import ForgeObservers

let connectivity = ConnectivityObserver()

// Read current status
if connectivity.status.isConnected {
    print("Online via \(connectivity.status.interface)")
}

// Check network conditions
if connectivity.status.isConstrained {
    print("Low Data Mode — reduce media quality")
}

// Subscribe to changes
Task {
    for await status in connectivity.statusStream {
        if status.isConnected {
            print("Connected via \(status.interface)")
        } else {
            print("Connection lost")
        }
    }
}
```

## All Observers

| Observer | Model | Protocol | Description |
|----------|-------|----------|-------------|
| `ConnectivityObserver` | `ConnectivityStatus` | `ConnectivityObserving` | Network reachability, interface type, Low Data Mode |
| `AppLifecycleObserver` | `AppLifecycleState` | `AppLifecycleObserving` | App lifecycle transitions (active, inactive, background) |
| `KeyboardObserver` | `KeyboardState` | `KeyboardObserving` | Keyboard visibility and frame changes |
| `AppearanceObserver` | `AppAppearance` | `AppearanceObserving` | System appearance (light/dark mode) |
| `LocaleObserver` | `AppLocale` | `LocaleObserving` | Locale changes (language, region) |
| `ProtectedDataObserver` | `ProtectedDataState` | `ProtectedDataObserving` | Protected data availability (Keychain, encrypted files) |
| `NotificationPermissionObserver` | `NotificationPermissionStatus` | `NotificationPermissionObserving` | Push notification permission status |

## ConnectivityStatus

The connectivity observer provides rich network information:

```swift
let status = connectivity.status

status.isConnected   // true if a network path is available
status.interface     // .wifi, .cellular, .wiredEthernet, .other, .none
status.isExpensive   // true on cellular or personal hotspot
status.isConstrained // true when Low Data Mode is enabled
```

## AsyncStream Usage

Every observer exposes an `AsyncStream` for reactive updates:

```swift
for await state in lifecycle.stateStream {
    switch state {
    case .active:
        await refreshData()
    case .inactive:
        pauseTimers()
    case .background:
        saveState()
    }
}
```

All streams emit the current value on subscription. Cancellation is automatic with SwiftUI's `.task` modifier.

## Assign Extension

Combine-like `.assign(to:on:)` for binding stream values to properties:

```swift
@Observable
final class MyViewModel {
    private let connectivity: ConnectivityObserving
    private let keyboard: KeyboardObserving

    var isOffline = false
    var keyboardHeight: CGFloat = 0

    func startObserving() async {
        async let _: () = connectivity.statusStream
            .map { !$0.isConnected }
            .assign(to: \.isOffline, on: self)

        async let _: () = keyboard.stateStream
            .map { $0.height }
            .assign(to: \.keyboardHeight, on: self)
    }
}
```

## Thread Safety

All observers are `Sendable` and thread-safe. State is protected with `OSAllocatedUnfairLock`. Read `status`, `state`, or `current` from any context.

`AppearanceObserver` and `ProtectedDataObserver` require `@MainActor` for initialization because they read UIKit state. Once created, all properties are nonisolated.

## Forge Ecosystem

ForgeObservers is part of the **Forge** family of Swift packages for iOS:

| Package | Description |
|---------|-------------|
| [ForgeCore](https://github.com/stefanprojchev/ForgeCore) | Thread-safe utilities — `LockedState` and `SendableFileManager` |
| [ForgeInject](https://github.com/stefanprojchev/ForgeInject) | Lightweight dependency injection with property wrapper |
| **ForgeObservers** | Reactive system observers (connectivity, lifecycle, keyboard, and more) |
| [ForgeStorage](https://github.com/stefanprojchev/ForgeStorage) | Type-safe persistence — key-value, file storage, and Keychain |
| [ForgeBackgroundTasks](https://github.com/stefanprojchev/ForgeBackgroundTasks) | BGTaskScheduler registration, scheduling, and dispatch |
| [ForgeLocation](https://github.com/stefanprojchev/ForgeLocation) | Location-based triggers — geofencing, significant changes, visits |
| [ForgePush](https://github.com/stefanprojchev/ForgePush) | Push notification management — permissions, tokens, silent and visible routing |
| [ForgeOrchestrator](https://github.com/stefanprojchev/ForgeOrchestrator) | Sequence, pipeline, and monitor orchestrators for iOS app flows |

## License

MIT License. See [LICENSE](LICENSE) for details.
