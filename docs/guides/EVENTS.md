# Events

**Pattern**: EventViewModel pub/sub for cross-module communication

## Available Events

```swift
enum Event {
    case userLoggedIn
    case userLoggedOut
    case profileUpdated
    case userSubscribed
    case appRatingRequested
    case networkConnectivityChanged(isConnected: Bool)
}
```

## Subscribe to Events

```swift
@LazyInjected(\.eventViewModel) private var eventViewModel

init() {
    eventViewModel.subscribe(
        for: self,
        to: [.authentication, .subscription],
        handler: { [weak self] event in
            Task { @MainActor in
                self?.handleEvent(event)
            }
        }
    )
}

private func handleEvent(_ event: EventViewModel.Event) {
    switch event {
    case .userLoggedIn:
        // Refresh data
    case .userSubscribed:
        // Unlock features
    default:
        break
    }
}

deinit {
    Container.shared.eventViewModel().unsubscribe(self)
}
```

## Emit Events

```swift
@LazyInjected(\.eventViewModel) private var eventViewModel

func saveProfile() async {
    // Save logic...
    eventViewModel.emit(.profileUpdated)
}
```

## Event Types

Filter by category:

```swift
.authentication    // Login/logout
.profile          // Profile changes
.subscription     // Subscription changes
.appRating        // Review requests
.network          // Network status
```

## Adding Custom Events

In `EventViewModel.swift`:

```swift
enum Event: Equatable {
    // Existing...
    case orderCompleted(orderId: String)  // Add this
}

enum EventType {
    // Existing...
    case orders  // Add this
}

private func eventType(for event: Event) -> EventType {
    switch event {
    // Existing cases...
    case .orderCompleted: return .orders
    }
}
```

**Reference**: `Src/Features/Events/Events/EventViewModel.swift`

**Usage example**: `Src/iOSJumpstart/iOSJumpstart/App/RootViewModel.swift:45-85`
