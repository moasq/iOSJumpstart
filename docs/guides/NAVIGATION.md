# Navigation Guide

**Time**: 5 minutes
**Pattern**: AppRoute enum + AppNavigator + navigationDestination

Learn how to add new screens and navigate between them in your iOS Starter Kit.

---

## How Navigation Works

The app uses SwiftUI's `NavigationStack` with a centralized routing system:

1. **AppRoute** - Enum defining all possible routes
2. **AppNavigator** - ObservableObject managing navigation state
3. **Navigation Modifier** - Maps routes to actual views

**Key Files**:
- `Src/iOSJumpstart/iOSJumpstart/App/Navigation/AppNavigation.swift`
- `Src/iOSJumpstart/iOSJumpstart/App/MainTabView.swift`

---

## Adding a New Screen

### Step 1: Define Your Route

Open `AppNavigation.swift` and add your route to the `AppRoute` enum:

```swift
enum AppRoute: Hashable {
    case myProfile(userId: String? = nil)
    case settings(section: String? = nil)
    case showcase
    case more

    // ADD YOUR ROUTE:
    case productDetail(productId: String)
}
```

**File**: `Src/iOSJumpstart/iOSJumpstart/App/Navigation/AppNavigation.swift:14-20`

### Step 2: Map Route to View

In the same file, add your view mapping in `AppNavigatorModifier`:

```swift
@ViewBuilder
private func destinationView(for route: AppRoute) -> some View {
    switch route {
    case .myProfile(let userId):
        MyProfileView(userId: userId, onDeleteAccount: onDeleteAccount)
    case .settings(let section):
        SettingsView(section: section, onDeleteAccount: onDeleteAccount)

    // ADD YOUR MAPPING:
    case .productDetail(let productId):
        ProductDetailView(productId: productId)

    case .showcase, .more:
        EmptyView()
    }
}
```

**File**: `Src/iOSJumpstart/iOSJumpstart/App/Navigation/AppNavigation.swift:76-95`

### Step 3: Navigate to Your Screen

From any view with access to `AppNavigator`, navigate to your new screen:

```swift
@EnvironmentObject private var navigator: AppNavigator

Button("View Product") {
    navigator.navigate(to: .productDetail(productId: "123"))
}
```

**Full example**: `Src/iOSJumpstart/iOSJumpstart/App/MainTabView.swift:45`

---

## Navigation Patterns

### Push a New Screen

```swift
navigator.navigate(to: .myProfile())
```

### Pop to Root

```swift
navigator.popToRoot()
```

### Navigate to Specific Tab

```swift
navigator.navigateToTab(0)  // Index of tab (0 = first tab)
```

### Pass Data to Screen

```swift
// Route with parameters
case .userProfile(userId: String, isEditable: Bool)

// Navigate with data
navigator.navigate(to: .userProfile(userId: "123", isEditable: true))

// Receive in view
struct UserProfileView: View {
    let userId: String
    let isEditable: Bool

    var body: some View {
        // Use the data
    }
}
```

---

## Complete Example

### Scenario: Add a Settings Detail Screen

**1. Define route** in `AppRoute`:

```swift
case settingsDetail(setting: String)
```

**2. Map to view** in `destinationView`:

```swift
case .settingsDetail(let setting):
    SettingsDetailView(setting: setting)
```

**3. Create the view**:

```swift
struct SettingsDetailView: View {
    let setting: String

    var body: some View {
        Text("Settings: \(setting)")
            .navigationTitle("Settings")
    }
}
```

**4. Navigate from settings**:

```swift
struct SettingsView: View {
    @EnvironmentObject private var navigator: AppNavigator

    var body: some View {
        List {
            Button("Account Settings") {
                navigator.navigate(to: .settingsDetail(setting: "account"))
            }
        }
    }
}
```

---

## Tab-Specific vs. Global Navigation

### Tab-Specific Screens
Routes like `.myProfile` and `.settings` push onto the current tab's navigation stack.

### Tab Switching
Routes like `.showcase` and `.more` switch to that tab instead of pushing:

```swift
case .showcase:
    navigator.navigateToTab(0)
case .more:
    navigator.navigateToTab(1)
```

---

## Reference

**Route Enum**: `AppNavigation.swift:14-20`
**View Mapping**: `AppNavigation.swift:76-95`
**Navigator Usage**: `MainTabView.swift:45`
**Tab Integration**: `AuthenticatedRootView.swift:30-35`

---

## Next Steps

- [Add Tabs](./TABS.md) - Add new tabs to TabView
- [Deep Links](../reference/DEEP_LINKING.md) - Navigate from URLs
- [Architecture](../reference/ARCHITECTURE.md) - System architecture
