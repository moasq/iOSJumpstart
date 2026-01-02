# Troubleshooting Guide

Common issues and solutions for the iOS Starter Kit.

---

## Table of Contents

- [Build Issues](#build-issues)
- [Runtime Issues](#runtime-issues)
- [Authentication Issues](#authentication-issues)
- [Backend Issues](#backend-issues)
- [Subscription Issues](#subscription-issues)
- [Network Issues](#network-issues)
- [Debugging Tips](#debugging-tips)
- [Getting Help](#getting-help)

---

## Build Issues

### ❌ "No such module 'Authentication'" (or other module)

**Symptoms**: Build fails with error about missing module.

**Causes**:
- Xcode's derived data is corrupted
- Framework not properly linked
- Opened `.xcodeproj` instead of `.xcworkspace`

**Solutions**:

1. **Clean derived data**:
```bash
# Close Xcode first
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reopen workspace
open iOSJumpstart.xcworkspace
```

2. **Clean build folder in Xcode**:
```
Product → Clean Build Folder (⇧⌘K)
```

3. **Verify you opened workspace**:
```bash
# Always use .xcworkspace
open iOSJumpstart.xcworkspace

# NOT this:
# open Src/iOSJumpstart/iOSJumpstart.xcodeproj
```

4. **Check framework linking**:
- Select project → Target → General
- Scroll to "Frameworks, Libraries, and Embedded Content"
- Ensure all feature frameworks are present

---

### ❌ "Signing for iOSJumpstart requires a development team"

**Symptoms**: Build fails with signing error.

**Solution**:

1. In Xcode, select project → iOSJumpstart target → Signing & Capabilities
2. **Team** dropdown → Select your Apple Developer Account
3. If not listed:
   - **Xcode** → **Settings** (⌘,)
   - **Accounts** tab
   - Click **(+)** → **Apple ID**
   - Sign in with your Apple Developer credentials
   - Ensure enrollment is **Active** (not just created)

---

### ❌ Build fails with SwiftData errors

**Symptoms**: Errors about `@Model`, `ModelContext`, or `PersistentModel`.

**Cause**: iOS deployment target too low.

**Solution**:

1. Select project → iOSJumpstart target → General
2. **Deployment Info** → **iOS** → Set to **17.0** or later
3. Clean and rebuild

---

### ❌ "Type 'Factory' has no member 'shared'"

**Symptoms**: Factory dependency injection not working.

**Cause**: Factory package not imported or outdated.

**Solution**:

1. Check Package Dependencies:
   - File → Packages → Resolve Package Versions
2. Ensure Factory is added:
   - Project → Package Dependencies
   - Should see `Factory` package
3. Import in files:
```swift
import Factory
```

---

### ❌ Build succeeds but app crashes immediately

**See**: [Runtime Issues](#runtime-issues) section below.

---

## Runtime Issues

### ❌ App crashes on launch with no error

**Symptoms**: App installs but crashes immediately on launch.

**Debugging Steps**:

1. **Open Console** (⇧⌘Y in Xcode)
2. Look for error messages in red
3. Common errors and solutions below

---

### ❌ "Could not load AppConfiguration"

**Symptoms**:
```
Fatal error: Could not find AppConfiguration.Supabase.url
```

**Cause**: `AppConfiguration.swift` missing or not in target.

**Solution**:

1. Check file exists:
```bash
ls -l Src/Features/Common/Common/Configuration/AppConfiguration.swift
```

2. If missing, create it:
```bash
cd Src/Features/Common/Common/Configuration/
cp AppConfiguration.template AppConfiguration.swift
# Edit and fill in your credentials
```

3. Verify target membership:
   - Select `AppConfiguration.swift` in Xcode
   - File Inspector (right panel)
   - **Target Membership**: Check **Common**

---

### ❌ "Supabase URL or key is invalid"

**Symptoms**: App crashes or authentication fails with Supabase error.

**Solution**:

1. Verify credentials in `AppConfiguration.swift`:
```swift
public enum Supabase {
    public static let url = "https://YOUR_PROJECT_ID.supabase.co"
    public static let anonKey = "eyJhbGciOiJIUzI1NiIsIn..."
}
```

2. Get correct values:
   - Go to [app.supabase.com](https://app.supabase.com)
   - Select your project
   - Settings → API
   - Copy **Project URL** and **anon public** key

3. Ensure no trailing slashes in URL

---

### ❌ "GoogleService-Info.plist not found"

**Symptoms**: Firebase initialization fails.

**Cause**: Missing or incorrectly placed Firebase config file.

**Solution**:

1. Download from Firebase Console:
   - [console.firebase.google.com](https://console.firebase.google.com)
   - Select project → iOS app
   - Download `GoogleService-Info.plist`

2. Add to project:
```bash
# Copy to correct location
cp ~/Downloads/GoogleService-Info.plist \
   Src/iOSJumpstart/iOSJumpstart/GoogleService-Info.plist
```

3. Verify in Xcode:
   - Select `GoogleService-Info.plist`
   - File Inspector → Target Membership
   - Check **iOSJumpstart**

---

## Authentication Issues

### ❌ Apple Sign-In fails with "Invalid Bundle ID"

**Symptoms**: Sign in with Apple shows error or doesn't work.

**Cause**: Bundle ID mismatch between app and Apple Developer Portal.

**Solution**:

1. **Verify Bundle ID in Xcode**:
   - Project → Target → Signing & Capabilities
   - Note the **Bundle Identifier** (e.g., `com.yourcompany.app`)

2. **Check Apple Developer Portal**:
   - Go to [developer.apple.com/account/resources/identifiers](https://developer.apple.com/account/resources/identifiers)
   - Find your App ID
   - Verify Bundle ID matches exactly

3. **Check Capabilities**:
   - In Xcode: Signing & Capabilities
   - Ensure **Sign in with Apple** capability is added
   - Check `iOSJumpstart.entitlements` file contains:
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

---

### ❌ Google Sign-In fails or doesn't redirect back

**Symptoms**: Google OAuth opens but doesn't return to app.

**Common Causes & Solutions**:

**1. Wrong Client ID in Info.plist**:

Check `Src/iOSJumpstart/iOSJumpstart/Info.plist`:
```xml
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
```

Should match the **iOS Client ID** from Google Cloud Console.

**2. Incorrect URL Scheme**:

In `Info.plist`, find `CFBundleURLTypes` → `CFBundleURLSchemes`:
```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
</array>
```

This should be your iOS Client ID **reversed** (remove the `.apps.googleusercontent.com` and add `com.googleusercontent.apps.` prefix).

**Example**:
- iOS Client ID: `123456789-abc.apps.googleusercontent.com`
- URL Scheme: `com.googleusercontent.apps.123456789-abc`

**3. Wrong Client ID in AppConfiguration.swift**:

```swift
public enum Google {
    // This should be iOS Client ID
    public static let clientID = "123456789-abc.apps.googleusercontent.com"
}
```

**4. Supabase Google Provider not configured**:

- Go to Supabase Dashboard → Authentication → Providers → Google
- Ensure it's **Enabled**
- **Client ID**: Should be **Web Client ID** (not iOS!)
- **Client Secret**: From Web Client creation
- **Authorized Client IDs**: Add your **iOS Client ID**

---

### ❌ "User session not found after login"

**Symptoms**: Login completes but app still shows auth screen.

**Debugging**:

1. Check Xcode Console for errors
2. Verify RootViewModel state updates:
```swift
// In RootViewModel.swift
func checkAuthStatus() async {
    // Should emit userLoggedIn event
}
```

3. Check EventViewModel is receiving events:
```swift
// Add debug logging
eventViewModel.emit(.userLoggedIn)
print("[DEBUG] User logged in event emitted")
```

---

## Backend Issues

### ❌ "RLS policy violation" or "permission denied"

**Symptoms**: Database queries fail with RLS (Row-Level Security) error.

**Cause**: Missing or incorrect RLS policies in Supabase.

**Solution**:

1. **Check you're authenticated**:
```swift
let user = try await supabase.auth.session.user
print("User ID: \(user.id)")
```

2. **Verify RLS policies** in Supabase Dashboard:
   - Database → Policies → `profiles` table
   - Should have policies for SELECT, INSERT, UPDATE, DELETE
   - Policies should check `auth.uid() = id`

3. **Re-run SQL from SUPABASE_SETUP_GUIDE.md**:
```sql
-- Enable RLS
alter table public.profiles enable row level security;

-- Policy: Users can read their own profile
create policy "Users can update own profile."
  on profiles for update
  using ( auth.uid() = id );
```

---

### ❌ Avatar upload fails with "Bucket not found"

**Symptoms**: File upload fails with error about missing bucket.

**Cause**: Storage bucket not created or misconfigured.

**Solution**:

1. **Check bucket exists**:
   - Supabase Dashboard → Storage
   - Should see bucket named **storage**

2. **Create bucket if missing**:
```sql
insert into storage.buckets (id, name, public)
values ('storage', 'storage', true);
```

3. **Verify RLS policies** for storage:
   - Storage → Policies
   - Should have policies for SELECT, INSERT, UPDATE, DELETE on `avatars/` folder

4. **Check bucket name in code**:
```swift
// Should be "storage", not "avatars"
let bucketName = "storage"
let path = "avatars/\(userId).jpg"
```

---

### ❌ Profile not created on signup

**Symptoms**: User signs up but no profile row in database.

**Cause**: Database trigger not working.

**Solution**:

1. **Check trigger exists**:
   - Supabase Dashboard → Database → Triggers
   - Should see `on_auth_user_created` trigger

2. **Re-create trigger**:
```sql
-- Function
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data ->> 'email',
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$$;

-- Trigger
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

3. **Test by creating a new user**

---

## Subscription Issues

### ❌ RevenueCat shows "No products available"

**Symptoms**: Paywall shows no products or products list is empty.

**Causes & Solutions**:

**1. API Key mismatch**:

Check `AppConfiguration.swift`:
```swift
public enum RevenueCat {
    #if DEBUG
    public static let apiKey = "test_..." // For sandbox
    #else
    public static let apiKey = "appl_..." // For production
    #endif
}
```

**2. Products not created**:
- Go to [app.revenuecat.com](https://app.revenuecat.com)
- Projects → Your Project → Products
- Create products for your app

**3. Products not attached to offering**:
- RevenueCat Dashboard → Offerings
- Create an offering (e.g., "default")
- Add packages and attach products

**4. StoreKit configuration not loaded**:

In Xcode:
- Editor → Default Transaction → StoreKit Configuration File
- Select `Products.storekit`

---

### ❌ "Entitlement not found"

**Symptoms**: Subscription check fails with entitlement error.

**Solution**:

1. **Verify entitlement ID**:
   - RevenueCat Dashboard → Entitlements
   - Note the identifier (e.g., "pro")

2. **Update AppConfiguration.swift**:
```swift
public enum RevenueCat {
    public static let entitlementID = "pro" // Must match exactly
}
```

---

### ❌ Purchase fails in sandbox

**Symptoms**: Sandbox purchases don't complete.

**Common Issues**:

1. **Not signed in to sandbox account**:
   - Settings → App Store → Sandbox Account
   - Sign in with test account from App Store Connect

2. **Test account not created**:
   - App Store Connect → Users and Access → Sandbox Testers
   - Create test account

3. **StoreKit config issues**:
   - Ensure `Products.storekit` has products defined
   - Products match RevenueCat configuration

---

## Network Issues

### ❌ Network banner always shows "No Connection"

**Symptoms**: Red banner always visible even with internet.

**Debugging**:

1. **Check simulator network**:
   - Simulator → Settings → Wi-Fi
   - Ensure Wi-Fi is enabled and connected

2. **Restart NetworkMonitor**:
   - Stop app (⌘.)
   - Clean build folder (⇧⌘K)
   - Run again (⌘R)

3. **Check NetworkMonitor implementation**:
```swift
// Should detect network status
print("Network connected: \(networkMonitor.isConnected)")
```

---

### ❌ App update checker not working

**Symptoms**: Force update overlay doesn't appear when it should.

**Causes & Solutions**:

**1. App Store ID not set**:

Update `AppConfiguration.swift`:
```swift
public enum App {
    // Get from App Store Connect
    public static let appStoreID = "1234567890"
}
```

**2. Version format incorrect**:

Check `Info.plist`:
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>  <!-- Should be semantic version -->
```

**3. iTunes API not responding**:
- Only works for apps published on App Store
- In development, use mock data for testing

---

## Debugging Tips

### Enable Verbose Logging

Add to `AppConfiguration.swift`:

```swift
public enum Debug {
    #if DEBUG
    public static let enableLogging = true

    public static func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        if enableLogging {
            let filename = (file as NSString).lastPathComponent
            print("[\(filename):\(line)] \(function) - \(message)")
        }
    }
    #endif
}
```

Use in code:
```swift
#if DEBUG
AppConfiguration.Debug.log("User signed in: \(user.id)")
#endif
```

---

### Debug Supabase Requests

```swift
// In SupabaseClient configuration
let client = SupabaseClient(
    supabaseURL: URL(string: AppConfiguration.Supabase.url)!,
    supabaseKey: AppConfiguration.Supabase.anonKey,
    options: .init(
        auth: .init(debug: true)  // Enable auth debug logs
    )
)
```

---

### Debug RevenueCat

```swift
// In AppDelegate or App initialization
import RevenueCat

Purchases.logLevel = .debug  // Enable verbose logging
```

---

### Test Without Services

Comment out service initialization to isolate issues:

```swift
// In AppDelegate.swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions...) {
    // FirebaseApp.configure()  // Commented out for testing
    // RevenueCat setup // Commented out
}
```

---

### Use Breakpoints

Set breakpoints in key locations:
- `RootViewModel.swift:45` - Auth state changes
- `AuthRepository.swift:120` - Sign-in methods
- `SubscriptionManager.swift:89` - Subscription checks

---

### Inspect UserDefaults

```swift
// Check what's stored
let defaults = UserDefaults.standard
print("Has seen onboarding: \(defaults.bool(forKey: "hasSeenOnboarding"))")
print("Dark mode: \(defaults.bool(forKey: "isDarkMode"))")
```

---

### Reset Simulator

If all else fails:

1. **Reset simulator**:
   - Simulator → Device → Erase All Content and Settings

2. **Delete app and rebuild**:
```bash
# Clean build
rm -rf ~/Library/Developer/Xcode/DerivedData

# Rebuild
open iOSJumpstart.xcworkspace
# Product → Clean Build Folder
# Product → Build
# Product → Run
```

---

## Getting Help

### Before Asking for Help

1. ✅ Check this troubleshooting guide
2. ✅ Review [SETUP.md](./SETUP.md) for setup issues
3. ✅ Check [ARCHITECTURE.md](./ARCHITECTURE.md) for architecture questions
4. ✅ Search [existing issues](https://github.com/yourusername/ios-starter-kit/issues)
5. ✅ Enable debug logging and gather error messages

### How to Ask for Help

When opening an issue, include:

1. **Environment**:
   - Xcode version
   - iOS version (simulator/device)
   - macOS version

2. **Steps to reproduce**:
   - What you did
   - What you expected
   - What actually happened

3. **Error messages**:
   - Console output
   - Screenshots
   - Crash logs

4. **What you've tried**:
   - Solutions attempted
   - Results

### Support Channels

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/yourusername/ios-starter-kit/issues)
- 💬 **Questions**: [GitHub Discussions](https://github.com/yourusername/ios-starter-kit/discussions)
- 📧 **Email**: support@yourapp.com

---

## Common Error Messages Reference

| Error | Likely Cause | See Section |
|-------|-------------|-------------|
| "No such module" | Derived data issue | [Build Issues](#build-issues) |
| "Signing requires team" | Missing Apple Developer account | [Build Issues](#build-issues) |
| "RLS policy violation" | Missing database policies | [Backend Issues](#backend-issues) |
| "Bucket not found" | Storage not configured | [Backend Issues](#backend-issues) |
| "Invalid Bundle ID" | Bundle ID mismatch | [Authentication Issues](#authentication-issues) |
| "No products available" | RevenueCat not configured | [Subscription Issues](#subscription-issues) |
| "Network not available" | NetworkMonitor issue | [Network Issues](#network-issues) |

---

**Still stuck?** Open an issue with details, and we'll help you out! 🚀
