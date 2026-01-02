# Adding Tabs Guide

**Time**: 5 minutes
**Pattern**: TabView with AppNavigator integration

Learn how to add new tabs to your iOS app's main navigation.

---

## How Tabs Work

The app uses SwiftUI's `TabView` with selection binding to `AppNavigator`:

- **TabView** - Container for tab-based navigation
- **AppNavigator** - Manages selected tab state
- **Tab Items** - Individual tabs with icons and labels

**Key File**: `Src/iOSJumpstart/iOSJumpstart/App/MainTabView.swift`

---

## Adding a New Tab

### Step 1: Create Your Tab View

Create a new SwiftUI view for your tab:

```swift
// Src/iOSJumpstart/iOSJumpstart/App/Tabs/Discover/DiscoverTab.swift

import SwiftUI

struct DiscoverTab: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Discover Content")
                }
                .padding()
            }
            .navigationTitle("Discover")
        }
    }
}
```

### Step 2: Add Tab to TabView

Open `MainTabView.swift` and add your tab:

```swift
struct MainTabView: View {
    @EnvironmentObject private var navigator: AppNavigator

    var body: some View {
        TabView(selection: $navigator.selectedTab) {
            // Existing Tab 1
            ShowcaseTab()
                .tag(0)
                .tabItem {
                    Label("Showcase", systemImage: "star.fill")
                }

            // Existing Tab 2
            MoreTab(/* ... */)
                .tag(1)
                .tabItem {
                    Label("More", systemImage: "ellipsis")
                }

            // NEW TAB 3 - Add here:
            DiscoverTab()
                .tag(2)
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
        }
        .tint(Theme.Colors.primary)
    }
}
```

**Important**: Each tab needs a unique `.tag()` value (0, 1, 2, etc.)

---

## Tab Navigation from Code

### Navigate to Your New Tab

From anywhere with `AppNavigator` access:

```swift
@EnvironmentObject private var navigator: AppNavigator

Button("Go to Discover") {
    navigator.navigateToTab(2)  // Tag number of your tab
}
```

---

## Tab with Deep Linking

To make your tab accessible via deep links:

### Step 1: Add Route to AppRoute

In `AppNavigation.swift`:

```swift
enum AppRoute: Hashable {
    case myProfile(userId: String? = nil)
    case settings(section: String? = nil)
    case showcase
    case more

    // ADD YOUR TAB ROUTE:
    case discover
}
```

### Step 2: Map Route in DeepLinkCoordinator

In `DeepLinkCoordinator.swift`:

```swift
private func mapToAppRoute(_ route: DeepLinkRoute) -> AppRoute? {
    let path = route.path.lowercased()

    switch path {
    case "profile":
        return .myProfile()
    case "settings":
        return .settings()
    case "showcase":
        return .showcase
    case "more":
        return .more

    // ADD YOUR MAPPING:
    case "discover":
        return .discover

    default:
        return nil
    }
}
```

### Step 3: Handle Tab Navigation

In `DeepLinkCoordinator.performNavigation`:

```swift
private func performNavigation(to route: AppRoute, with navigator: AppNavigator?) {
    switch route {
    case .showcase:
        navigator?.navigateToTab(0)
    case .more:
        navigator?.navigateToTab(1)

    // ADD YOUR TAB:
    case .discover:
        navigator?.navigateToTab(2)

    case .myProfile, .settings:
        navigator?.navigate(to: route)
    }
}
```

Now `yourapp://discover` will open the Discover tab!

---

## Complete Example

Here's the complete `MainTabView` with three tabs:

```swift
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var navigator: AppNavigator

    // Dependencies
    let onShowPaywall: () -> Void
    let onPresentDeleteAccount: () -> Void

    var body: some View {
        TabView(selection: $navigator.selectedTab) {
            // Tab 1: Showcase
            ShowcaseTab()
                .tag(0)
                .tabItem {
                    Label("Showcase", systemImage: "star.fill")
                }

            // Tab 2: Discover (NEW)
            DiscoverTab()
                .tag(1)
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }

            // Tab 3: More
            MoreTab(
                onMyProfileClicked: { navigator.navigate(to: .myProfile()) },
                onShowPaywall: onShowPaywall,
                onDeleteAccountRequested: onPresentDeleteAccount
            )
            .tag(2)
            .tabItem {
                Label("More", systemImage: "ellipsis")
            }
        }
        .tint(Theme.Colors.primary)
    }
}
```

---

## Tab Badges

Add a badge to show notifications or count:

```swift
DiscoverTab()
    .tag(1)
    .tabItem {
        Label("Discover", systemImage: "magnifyingglass")
    }
    .badge(5)  // Shows "5" badge
```

Or conditional badge:

```swift
.badge(hasNewContent ? "New" : nil)
```

---

## SF Symbols for Tab Icons

Use SF Symbols for consistent, professional tab icons:

**Common Icons**:
- `house.fill` - Home
- `magnifyingglass` - Search/Discover
- `star.fill` - Favorites/Showcase
- `person.fill` - Profile
- `gearshape.fill` - Settings
- `ellipsis` - More
- `bell.fill` - Notifications
- `cart.fill` - Shopping
- `book.fill` - Library

Browse all icons: [SF Symbols App](https://developer.apple.com/sf-symbols/)

---

## Tab Selection Persistence

The current tab selection is managed by `AppNavigator` and persists during the app session.

To save tab selection between app launches:

```swift
// In AppNavigator
@Published var selectedTab = UserDefaults.standard.integer(forKey: "selectedTab") {
    didSet {
        UserDefaults.standard.set(selectedTab, forKey: "selectedTab")
    }
}
```

---

## Best Practices

### Tab Limit
- **Ideal**: 3-5 tabs
- **Maximum**: 5 tabs (more requires "More" tab)
- Too many tabs create confusion

### Tab Order
- Put most important/frequently used tabs first
- Keep "More" or "Settings" last

### Tab Labels
- Use concise, single-word labels
- Match the icon meaning
- Be consistent with capitalization

### Navigation
- Each tab should have its own `NavigationStack`
- Don't nest TabViews
- Use tabs for distinct app sections, not related content

---

## Reference

**TabView Implementation**: `Src/iOSJumpstart/iOSJumpstart/App/MainTabView.swift`
**AppNavigator**: `Src/iOSJumpstart/iOSJumpstart/App/Navigation/AppNavigation.swift:25-35`
**Deep Link Integration**: `Src/iOSJumpstart/iOSJumpstart/App/Navigation/DeepLinkCoordinator.swift`

---

## Next Steps

- [Navigation](./NAVIGATION.md) - Add screens within tabs
- [Deep Linking](../reference/DEEP_LINKING.md) - Navigate from URLs
- [Architecture](../reference/ARCHITECTURE.md) - App structure
