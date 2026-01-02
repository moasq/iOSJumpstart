# Notifications

**Pattern**: Permission status checking + request flow

## Check Permission Status

```swift
@LazyInjected(\.notificationService) private var notificationService

let status = await notificationService.getPermissionStatus()

switch status {
case .notDetermined:
    // Can request permission
case .authorized, .provisional:
    // Notifications enabled
case .denied:
    // Need to guide user to Settings
}
```

## Request Permission

```swift
do {
    let deviceToken = try await notificationService.registerForPushNotifications()
    print("Device token: \(deviceToken)")
} catch {
    print("Permission denied")
}
```

## Open Settings

```swift
if let url = URL(string: UIApplication.openSettingsURLString) {
    UIApplication.shared.open(url)
}
```

## Complete Example

```swift
struct NotificationPermissionView: View {
    @State private var permissionStatus: NotificationPermission = .notDetermined
    @Injected(\.notificationService) private var notificationService

    var body: some View {
        VStack {
            Image(systemName: iconName)
            Text(title)
            Button(buttonTitle, action: handleButtonTap)
        }
        .task {
            permissionStatus = await notificationService.getPermissionStatus()
        }
    }

    private func handleButtonTap() {
        switch permissionStatus {
        case .notDetermined:
            requestPermission()
        case .denied, .authorized, .provisional:
            openSettings()
        }
    }

    private func requestPermission() {
        Task {
            try? await notificationService.registerForPushNotifications()
            permissionStatus = await notificationService.getPermissionStatus()
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
```

**Reference**: `Src/iOSJumpstart/iOSJumpstart/App/Onboarding/Pages/NotificationsPage.swift`

**Service**: `Src/iOSJumpstart/iOSJumpstart/Services/NotificationService/NotificationService.swift`
