# Deep Linking Architecture

## Overview

The deep linking system enables the app to respond to external URLs and navigate to specific screens. It supports both URL schemes (`iosjumpstart://`) and Universal Links (`https://iosjumpstart.app/`).

---

## Architecture

### Components

| Component | Responsibility | File Location |
|-----------|---------------|---------------|
| **DeepLinkHandler** | Entry point for all deep links | `Services/DeepLinkService/DeepLinkHandler.swift` |
| **DeepLinkParser** | Parses URLs into structured routes | `Services/DeepLinkService/DeepLinkParser.swift` |
| **DeepLinkRouter** | Routes parsed links to handlers | `Services/DeepLinkService/Router/DeepLinkRouter.swift` |
| **AppCoordinator** | Maps routes to app navigation | `App/Navigation/AppCoordinator.swift` |
| **DeepLinkCoordinatorFactory** | Creates coordinators with validation | `App/Navigation/DeepLinkCoordinatorFactory.swift` |
| **DeepLinkSetupModifier** | Manages coordinator lifecycle | `Services/DeepLinkService/DeepLinkSetupModifier.swift` |
| **DeepLinkReadiness** | Tracks initialization state | `App/Navigation/DeepLinkReadiness.swift` |

### Initialization Sequence

```
1. RootView appears
   └─> .setupDeepLinking() modifier applied
       └─> DeepLinkSetupModifier.onAppear
           └─> DeepLinkCoordinatorFactory.createCoordinator()
               ├─> Create AppCoordinator(navigator, viewModel)
               ├─> Set handler on router
               └─> Return configured coordinator

2. Auth check completes
   └─> DeepLinkSetupModifier.handleAuthStateChange()
       └─> If authenticated:
           └─> Update readiness to .fullyReady
               └─> Wait 300ms (UI stabilization)
                   └─> Process pending deep links

3. Deep link arrives
   └─> DeepLinkHandler.handle(url:)
       └─> Parser.parse(url:) → DeepLinkRoute
           └─> Router.route(to:) → AppCoordinator
               └─> AppCoordinator.route(to:)
                   ├─> Validate dependencies (throws if nil)
                   ├─> Map path to AppRoute
                   ├─> Check auth requirement
                   └─> Navigate (or defer if not ready)
```

---

## Readiness States

The system tracks initialization through explicit states:

```swift
enum DeepLinkReadiness {
    case notReady              // Initial state
    case coordinatorCreated    // Coordinator instantiated
    case handlerConfigured     // Handler set on router
    case fullyReady           // Auth resolved, can process all links
}
```

### State Transitions

```
App Launch
    ↓
.notReady
    ↓
DeepLinkSetupModifier.setupCoordinator()
    ↓
.coordinatorCreated (coordinator instantiated)
    ↓
.handlerConfigured (handler.setRouteHandler() called)
    ↓
Auth completes successfully
    ↓
.fullyReady (can process all deep links including protected routes)
```

### Routing Capabilities by State

| State | Can Route Public Links? | Can Route Protected Links? |
|-------|------------------------|---------------------------|
| notReady | ❌ No | ❌ No |
| coordinatorCreated | ❌ No | ❌ No |
| handlerConfigured | ✅ Yes | ❌ No |
| fullyReady | ✅ Yes | ✅ Yes |

---

## Link Processing Flow

### Public Links (No Auth Required)

```
URL arrives: iosjumpstart://showcase
    ↓
Parser: DeepLinkRoute(path: "showcase")
    ↓
AppCoordinator.route(to:)
    ├─ Validate dependencies ✅
    ├─ Map "showcase" → .showcase
    ├─ Check auth requirement → false
    └─ Navigate to Showcase tab immediately
```

### Protected Links (Auth Required)

#### Scenario 1: User is Authenticated

```
URL arrives: iosjumpstart://profile
    ↓
Parser: DeepLinkRoute(path: "profile")
    ↓
AppCoordinator.route(to:)
    ├─ Validate dependencies ✅
    ├─ Map "profile" → .myProfile
    ├─ Check auth requirement → true
    ├─ Check auth state → authenticated ✅
    └─ Navigate to profile immediately
```

#### Scenario 2: User is NOT Authenticated

```
URL arrives: iosjumpstart://profile
    ↓
Parser: DeepLinkRoute(path: "profile")
    ↓
AppCoordinator.route(to:)
    ├─ Validate dependencies ✅
    ├─ Map "profile" → .myProfile
    ├─ Check auth requirement → true
    ├─ Check auth state → not authenticated ❌
    └─ Return false (defers link)
        ↓
Router stores as pending link
        ↓
User authenticates
        ↓
DeepLinkSetupModifier detects auth success
        ↓
Wait 300ms for UI to stabilize
        ↓
deepLinkHandler.processPendingDeepLink()
        ↓
Retry: AppCoordinator.route(to:)
        ↓
Navigate to profile ✅
```

---

## Why Weak References?

`AppCoordinator` uses weak references to `AppNavigator` and `RootViewModel`:

```swift
private weak var navigator: AppNavigator?
private weak var viewModel: RootViewModel?
```

### Rationale

**Problem**: Without weak references, we'd have a retain cycle:
```
RootView (owns)
    ├─> RootViewModel
    ├─> AppNavigator
    └─> AppCoordinator
            ├─> strong ref to RootViewModel ❌
            └─> strong ref to AppNavigator ❌
                    └─> (could hold ref back to RootView)
```

**Solution**: Weak references break the cycle:
```
RootView (owns)
    ├─> RootViewModel
    ├─> AppNavigator
    └─> AppCoordinator
            ├─> weak ref to RootViewModel ✅
            └─> weak ref to AppNavigator ✅
```

### Safety Guarantees

1. **Validation Before Use**: Every routing operation validates dependencies first:
   ```swift
   private func validateDependencies() throws {
       guard navigator != nil else {
           throw CoordinatorError.navigatorDeallocated
       }
       guard viewModel != nil else {
           throw CoordinatorError.viewModelDeallocated
       }
   }
   ```

2. **Error Handling**: If dependencies become nil:
   - **Debug**: Assertion failure with clear message
   - **Production**: Log error, return false (defer link)

3. **Lifecycle Guarantee**: The coordinator is stored in `DeepLinkSetupModifier` which lives as long as RootView. Since RootView owns both navigator and viewModel, they can't be deallocated while the coordinator exists.

---

## Why the 300ms Delay?

After authentication succeeds, we wait 300ms before processing pending deep links:

```swift
/// Delay after authentication before processing pending deep links.
///
/// This ensures the navigation stack is fully initialized and ready
/// to accept navigation commands. Empirically determined to be the
/// minimum delay that reliably works across all device speeds.
private let pendingLinkProcessingDelay: TimeInterval = 0.3
```

### Why Is This Needed?

1. **SwiftUI Animations**: Auth success triggers view transitions with animations
2. **Navigation Stack Initialization**: NavigationStack needs to be in stable state
3. **Without Delay**: Navigation commands can be dropped or ignored

### Real-World Example

```
T=0ms    User logs in successfully
T=0ms    RootView transitions from auth page to MainTabView
T=0-300ms SwiftUI runs transition animations
T=300ms   Navigation stack is fully initialized
T=300ms   Process pending deep link → Navigate to profile ✅
```

Without the delay:
```
T=0ms    User logs in
T=0ms    Try to navigate → NavigationStack not ready → Command dropped ❌
```

### Alternatives Considered

| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| **No delay** | Simple | Unreliable, drops links | ❌ Rejected |
| **Polling until ready** | Guaranteed to work | Wasteful, complex | ❌ Rejected |
| **Combine publisher** | Reactive, elegant | Too complex, overkill | ❌ Rejected |
| **Fixed 300ms delay** | Simple, reliable | Not instant | ✅ **Chosen** |

### Why 300ms Specifically?

- **Too short** (e.g., 100ms): Unreliable on slower devices
- **Too long** (e.g., 1000ms): Noticeable delay for users
- **300ms**: Empirically determined minimum that works across all device speeds

---

## Error Handling

### Dependency Validation Failures

**When**: Coordinator's weak references become nil (should never happen in normal operation)

**Debug Mode**:
```swift
try validateDependencies()
// Throws CoordinatorError.navigatorDeallocated or viewModelDeallocated
    ↓
logError("❌ Dependency validation failed: \(error)")
    ↓
assertionFailure("AppCoordinator dependency became nil: \(error)")
    ↓
App crashes with clear error message
```

**Production Mode**:
```swift
try validateDependencies()
// Throws error
    ↓
logError("❌ Dependency validation failed: \(error)")
    ↓
return false (defer the link)
    ↓
Link is saved as pending, will retry later
```

### Unknown Routes

**When**: Deep link path doesn't map to any AppRoute

**Example**:
```
URL: iosjumpstart://unknown-page
    ↓
AppCoordinator.mapToAppRoute("unknown-page")
    ↓
throw CoordinatorError.unknownRoute
    ↓
log("❌ Failed to map route: \(error)")
    ↓
return false (not handled)
```

---

## Supported Deep Links

| URL | Destination | Auth Required? | Tab or Navigation? | Parameters |
|-----|-------------|----------------|-------------------|------------|
| `iosjumpstart://showcase` | Showcase Tab | ❌ No | Tab (index 0) | None |
| `iosjumpstart://more` | More Tab | ❌ No | Tab (index 1) | None |
| `iosjumpstart://profile` | My Profile View | ✅ Yes | Navigation push | `userId` (optional) |
| `iosjumpstart://settings` | Settings View | ✅ Yes | Navigation push | `section` (optional) |

### URL Parameters

Deep links support URL query parameters that get passed to the destination views:

```bash
# Navigate to profile with specific user ID
xcrun simctl openurl booted "iosjumpstart://profile?userId=abc123"

# Navigate to settings with specific section
xcrun simctl openurl booted "iosjumpstart://settings?section=notifications"
```

Parameters are extracted from the URL and passed through the routing system:
- `DeepLinkRoute` contains `parameters: [String: String]` dictionary
- `AppCoordinator.mapToAppRoute()` extracts parameters
- `AppRoute` enum uses associated values (e.g., `.myProfile(userId: String?)`)
- Destination views receive parameters for conditional rendering

---

## Common Pitfalls

### 1. Missing .setupDeepLinking() Modifier

**Problem**: Deep links don't work at all, or you see an assertion in debug builds.

**Symptoms**:
```
❌ DEEP LINK SETUP ERROR ❌
Missing .setupDeepLinking() modifier on RootView.
```

**Cause**: RootView requires **TWO** modifiers for deep linking to work:
```swift
// In RootView.swift
.setupDeepLinking(authStateProvider: viewModel, navigator: navigator)  // ← Creates coordinator
.handleDeepLinks(with: deepLinkHandler)                                 // ← Handles URLs
```

**Solution**: Add both modifiers to RootView. The order matters - `.setupDeepLinking()` must come first.

**Location**: After the `.task` block in `RootView.swift`:
```swift
.task {
    await viewModel.checkAuthStatus()
}
.setupDeepLinking(authStateProvider: viewModel, navigator: navigator)  // ← Add this
.handleDeepLinks(with: deepLinkHandler)                                 // ← Already present
```

---

### 2. Adding Routes Without Updating All Switches

**Problem**: Compiler error when adding new route: "Switch must be exhaustive"

**This is intentional** - it's a feature, not a bug! ✅

**Why**: All switches in the routing system deliberately have **no `default` case**. This forces you to handle every route explicitly.

**When you add a new route to `AppRoute` enum**, you **must** update **4 switches**:

1. **AppNavigatorModifier.swift** - `destinationView(for:)`
   - Map route to its view
2. **AppCoordinator.swift** - `performNavigation(to:)`
   - Handle navigation action
3. **AppCoordinator.swift** - `mapToAppRoute(_:)`
   - Map URL path to route
4. **AppCoordinator.swift** - `requiresAuth(_:)`
   - Define auth requirement

**This ensures**:
- You can't forget to handle a new route
- Compiler catches mistakes at build time
- No runtime errors from unhandled routes

**Example**:
```swift
// 1. Add to AppRoute enum
enum AppRoute {
    case showcase
    case more
    case myProfile(userId: String? = nil)
    case settings(section: String? = nil)
    case newRoute  // ← Added
}

// 2. Compiler errors in 4 places until you handle .newRoute in each switch
```

---

### 3. Using Strong References in AppCoordinator

**Problem**: Memory leaks or retain cycles

**Cause**: AppCoordinator holds references to `AppNavigator` and `RootViewModel`, which are owned by RootView.

**Solution**: Always use **weak references**:
```swift
private weak var navigator: AppNavigator?
private weak var authStateProvider: (any AuthStateProvider)?
```

**Why**: RootView owns coordinator, navigator, and viewModel. Without weak refs, you create a retain cycle.

**The coordinator validates dependencies** before each use:
```swift
private func validateDependencies() throws {
    guard navigator != nil else {
        throw CoordinatorError.navigatorDeallocated
    }
    // ...
}
```

If the validation fails, it's a lifecycle bug that needs fixing.

---

### 4. Forgetting to Handle Associated Values

**Problem**: Compiler error: "Pattern match introduces immutable values; use 'let' to capture them"

**Cause**: Routes with parameters require extracting associated values in pattern matching.

**Wrong**:
```swift
case .myProfile:  // ❌ Error - route has associated value
    MyProfileView()
```

**Correct**:
```swift
case .myProfile(let userId):  // ✅ Extract parameter
    MyProfileView()  // Can use userId if needed
```

**All parameterized routes**:
- `.myProfile(userId: String?)` - Must use `case .myProfile(let userId):`
- `.settings(section: String?)` - Must use `case .settings(let section):`

---

### 5. Combining Cases in Switches

**Problem**: Compiler error after combining cases: "Switch must be exhaustive"

**Cause**: While Swift allows combining cases (e.g., `case .showcase, .more:`), we **intentionally avoid this** for clarity and compiler enforcement.

**Wrong** (will cause issues later):
```swift
case .showcase, .more:  // ❌ Don't combine
    return false
```

**Correct**:
```swift
case .showcase:
    return false
case .more:
    return false
// NO DEFAULT - compiler enforces exhaustiveness
```

**Why**: When you add a new route, you want the compiler to force you to explicitly decide what to do with it, not have it accidentally fall into a combined case.

---

## Testing Guide

### Manual Testing (Simulator)

#### Test Public Routes
```bash
# Showcase tab (should work immediately)
xcrun simctl openurl booted "iosjumpstart://showcase"

# More tab (should work immediately)
xcrun simctl openurl booted "iosjumpstart://more"
```

**Expected**: Tab switches immediately to selected tab.

#### Test Protected Routes (When Authenticated)
```bash
# Ensure user is logged in first
# Then test protected routes

xcrun simctl openurl booted "iosjumpstart://profile"
xcrun simctl openurl booted "iosjumpstart://settings"
```

**Expected**: Navigates to the selected view immediately.

#### Test Auth Deferral (When Logged Out)
```bash
# 1. Ensure user is logged out
# 2. Send deep link to protected route
xcrun simctl openurl booted "iosjumpstart://profile"

# Expected: App shows auth page (NOT profile)

# 3. Complete login
# Expected: After ~300ms, automatically navigates to profile ✅
```

### Debug Logs

Enable debug logging to trace the deep link flow:

```
🔗 DeepLinkSetup: Setting up coordinator...
🏭 DeepLinkCoordinatorFactory: 📦 Creating coordinator...
🏭 DeepLinkCoordinatorFactory: 📦 Coordinator created
🏭 DeepLinkCoordinatorFactory: 📦 Handler configured
🏭 DeepLinkCoordinatorFactory: ✅ Coordinator ready for use
🔗 DeepLinkSetup: ✅ Setup complete. Readiness: handlerConfigured
🔗 DeepLinkRouter: Routing to handler: showcase
🔗 AppCoordinator: 📍 Routing to: showcase
🔗 AppCoordinator: 📍 Mapped to AppRoute: showcase
🔗 AppCoordinator: ✅ Public route, navigating to showcase
🔗 AppCoordinator: ✅ Navigated to Showcase tab
```

### Unit Testing

**Test DeepLinkCoordinatorFactory**:
```swift
func testFactoryCreatesCoordinator() {
    let navigator = AppNavigator()
    let viewModel = RootViewModel()
    let handler = DeepLinkHandler()

    let result = DeepLinkCoordinatorFactory.createCoordinator(
        navigator: navigator,
        viewModel: viewModel,
        handler: handler
    )

    XCTAssertSuccess(result)
}
```

**Test AppCoordinator Routing**:
```swift
func testPublicRouteNavigatesImmediately() {
    let coordinator = AppCoordinator(navigator: navigator, viewModel: viewModel)
    let route = DeepLinkRoute(path: "showcase", queryItems: [])

    let handled = coordinator.route(to: route)

    XCTAssertTrue(handled)
    XCTAssertEqual(navigator.selectedTab, 0)
}

func testProtectedRouteDefersWhenNotAuthenticated() {
    viewModel.authState = .result(false) // Not authenticated
    let coordinator = AppCoordinator(navigator: navigator, viewModel: viewModel)
    let route = DeepLinkRoute(path: "profile", queryItems: [])

    let handled = coordinator.route(to: route)

    XCTAssertFalse(handled) // Link is deferred
}
```

---

## Common Issues & Solutions

### Issue: Deep Links Not Working

**Symptoms**: Tapping a deep link does nothing

**Debug Steps**:
1. Check logs for readiness state
   - Look for: `🔗 DeepLinkSetup: ✅ Setup complete. Readiness: handlerConfigured`
2. Verify handler is set on router
   - Look for: `🏭 DeepLinkCoordinatorFactory: 📦 Handler configured`
3. Check auth state if link requires auth
   - Look for: `🔗 AppCoordinator: 📍 Auth required. Current auth state: false`

**Common Causes**:
- Coordinator not set up (check RootView has `.setupDeepLinking()` modifier)
- Handler set too late (should be in onAppear, before .task)
- Auth state not resolved yet (wait for auth check to complete)

**Solution**: Verify initialization sequence in logs.

---

### Issue: Protected Routes Don't Navigate After Login

**Symptoms**: User logs in, but doesn't navigate to deferred deep link

**Debug Steps**:
1. Check if link was deferred
   - Look for: `⏸️ Auth required for myProfile, deferring link`
2. Check if pending link is processed after auth
   - Look for: `🔗 DeepLinkSetup: Auth success. Readiness: fullyReady`
   - Look for: `🔗 DeepLinkSetup: Processing pending deep links...`

**Common Causes**:
- 300ms delay not completing (app backgrounded during delay)
- DeepLinkSetupModifier not observing authState changes
- Pending link cleared before processing

**Solution**: Ensure `.setupDeepLinking()` modifier is applied and observes authState.

---

### Issue: "Dependency became nil" Assertion

**Symptoms**: Debug assertion failure: "AppCoordinator dependency became nil"

**This should NEVER happen in normal operation.**

**Possible Causes**:
- RootView deallocated while coordinator still exists
- Navigator or ViewModel deallocated independently
- Lifecycle bug in view hierarchy

**Debug Steps**:
1. Check if RootView is being recreated unexpectedly
2. Verify coordinator is stored in `DeepLinkSetupModifier` (strong reference)
3. Check for accidental nil assignment to navigator or viewModel

**Solution**: Fix lifecycle management bug. The weak references are correct; the issue is in how the objects are being retained.

---

### Issue: Navigation Commands Dropped After Login

**Symptoms**: Deep link is processed but navigation doesn't happen

**Common Causes**:
- 300ms delay too short (UI not ready)
- NavigationStack in transition state
- Multiple rapid navigation commands

**Debug Steps**:
1. Check if navigation command is issued
   - Look for: `✅ Navigated to myProfile`
2. Check timing of command relative to UI changes
3. Try increasing delay temporarily to diagnose

**Solution**: If 300ms is too short on your device, increase `pendingLinkProcessingDelay` in `DeepLinkSetupModifier.swift`.

---

## Adding New Deep Links

When you add a new route, you **must** update **4 locations**. The compiler will enforce this by showing errors until all switches are updated (no `default` cases means exhaustiveness is required).

### Step 1: Add Route to AppRoute Enum

**File**: `App/Navigation/AppRoute.swift`

```swift
enum AppRoute: Hashable {
    case myProfile(userId: String? = nil)
    case settings(section: String? = nil)
    case showcase
    case more
    case productDetail(productId: String)  // ← Add new route with parameter
}
```

**Note**: Use optional parameters with defaults for backward compatibility if needed.

### Step 2: Map URL Path to AppRoute

**File**: `App/Navigation/AppCoordinator.swift` - `mapToAppRoute()` method

```swift
private func mapToAppRoute(_ route: DeepLinkRoute) throws -> AppRoute {
    let normalizedPath = route.path.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "/"))

    switch normalizedPath {
    case "profile":
        let userId = route.parameters["userId"]
        return .myProfile(userId: userId)
    case "settings":
        let section = route.parameters["section"]
        return .settings(section: section)
    case "showcase":
        return .showcase
    case "more":
        return .more
    case "product":  // ← Add path mapping
        guard let productId = route.parameters["id"] else {
            throw CoordinatorError.unknownRoute
        }
        return .productDetail(productId: productId)
    }

    // If no case matched, throw error (NO DEFAULT CASE)
    log("❌ Unknown route: \(route.path)")
    throw CoordinatorError.unknownRoute
}
```

### Step 3: Define Auth Requirement

**File**: `App/Navigation/AppCoordinator.swift` - `requiresAuth()` method

```swift
private func requiresAuth(_ route: AppRoute) -> Bool {
    switch route {
    case .myProfile:
        return true
    case .settings:
        return true
    case .showcase:
        return false
    case .more:
        return false
    case .productDetail:  // ← Add auth requirement
        return false  // Public route
    }
    // NO DEFAULT - compiler enforces exhaustiveness
}
```

### Step 4: Handle Navigation Action

**File**: `App/Navigation/AppCoordinator.swift` - `performNavigation()` method

```swift
private func performNavigation(to appRoute: AppRoute) {
    guard let navigator else {
        log("❌ Navigator not available")
        return
    }

    switch appRoute {
    case .showcase:
        navigator.navigateToTab(0)
        log("✅ Navigated to Showcase tab")
    case .more:
        navigator.navigateToTab(1)
        log("✅ Navigated to More tab")
    case .myProfile(let userId):
        navigator.navigate(to: appRoute)
        log("✅ Navigated to profile\(userId.map { " (userId: \($0))" } ?? "")")
    case .settings(let section):
        navigator.navigate(to: appRoute)
        log("✅ Navigated to settings\(section.map { " (section: \($0))" } ?? "")")
    case .productDetail(let productId):  // ← Handle navigation
        navigator.navigate(to: appRoute)
        log("✅ Navigated to product: \(productId)")
    }
    // NO DEFAULT - compiler enforces exhaustiveness
}
```

### Step 5: Map Route to View

**File**: `App/Navigation/AppNavigatorModifier.swift` - `destinationView()` method

```swift
@ViewBuilder
private func destinationView(for route: AppRoute) -> some View {
    switch route {
    case .myProfile(let userId):
        MyProfileView(onDeleteAccount: onDeleteAccount)
    case .settings(let section):
        SettingsView(onDeleteAccount: onDeleteAccount)
    case .showcase:
        EmptyView()
    case .more:
        EmptyView()
    case .productDetail(let productId):  // ← Add view mapping
        ProductDetailView(productId: productId)
    }
    // NO DEFAULT - compiler will error if new route added without handling
}
```

### Step 6: Test

```bash
# Test basic route
xcrun simctl openurl booted "iosjumpstart://product?id=abc123"

# Verify parameter is passed correctly
# Check console logs for: "✅ Navigated to product: abc123"
```

**Compiler Guarantees**:
- If you add a route to `AppRoute` enum but forget to handle it in any of the 4 switches, you'll get a compiler error
- This prevents runtime errors from unhandled routes
- **This is intentional and a good thing!** ✅

---

## Universal Links (Production)

To enable production Universal Links (e.g., `https://iosjumpstart.app/profile`):

### Step 1: Add Associated Domains Entitlement

**File**: `iOSJumpstart.entitlements`

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:iosjumpstart.app</string>
</array>
```

### Step 2: Host apple-app-site-association File

**URL**: `https://iosjumpstart.app/.well-known/apple-app-site-association`

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.iosjumpstart.app",
        "paths": [
          "/profile",
          "/settings",
          "/showcase",
          "/more"
        ]
      }
    ]
  }
}
```

**Note**: Replace `TEAM_ID` with your Apple Developer Team ID.

### Step 3: Verify

```bash
# Test Universal Link
open "https://iosjumpstart.app/profile"
```

---

## Summary

The deep linking system is now:

✅ **Clean**: Clear separation of concerns
✅ **Safe**: Error handling with validation
✅ **Explicit**: Readiness tracking
✅ **Documented**: Comprehensive guides
✅ **Testable**: Factory pattern, isolated components
✅ **Maintainable**: Single responsibility per component

For questions or issues, refer to:
- This documentation for architecture and flow
- Inline code comments for implementation details
- Debug logs for runtime debugging
