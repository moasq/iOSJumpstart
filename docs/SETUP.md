# Complete Setup Guide

Get your iOS Starter Kit running in **45-60 minutes**.

**Requirements**: macOS, Xcode 16+, iOS 18+

---

## Setup Steps

| # | Task | Time | Guide |
|---|------|------|-------|
| 1 | Apple Developer Setup | 15 min | [→ Guide](./setup/APPLE_DEVELOPER.md) |
| 2 | Clone Project | 2 min | Inline below |
| 3 | Xcode Configuration | 5 min | [→ Guide](./setup/XCODE_CONFIG.md) |
| 4 | Supabase Backend | 12 min | [→ Guide](./SUPABASE_SETUP_GUIDE.md) |
| 5 | Firebase (Optional) | 8 min | [→ Guide](./setup/FIREBASE.md) |
| 6 | Google OAuth | 10 min | [→ Guide](./setup/GOOGLE_OAUTH.md) |
| 7 | RevenueCat | 10 min | [→ Guide](./REVENUECAT_SETUP_GUIDE.md) |
| 8 | App Configuration | 5 min | [→ Guide](./setup/APP_CONFIGURATION.md) |
| 9 | Build & Run | 2 min | Inline below |

---

## 2. Clone Project

```bash
git clone https://github.com/yourusername/ios-starter-kit.git
cd ios-starter-kit
open iOSJumpstart.xcworkspace
```

**Important**: Always open `.xcworkspace`, NOT `.xcodeproj`

### Optional: Rename App

```bash
./scripts/rename_app.sh iOSJumpstart YourAppName
./scripts/change_bundle_id.sh com.mosal com.yourname
```

---

## 9. Build & Run

### Build

1. In Xcode, select a simulator (e.g., iPhone 15 Pro)
2. Press **⌘B** or Product → Build
3. Wait for build to complete

### Run

1. Press **⌘R** or Product → Run
2. App should launch in simulator
3. Complete onboarding flow
4. Test sign-in with Apple or Google

### Verify

Test these features:

- ✅ Sign in with Apple works
- ✅ Google Sign-In works
- ✅ User profile loads
- ✅ Subscription paywall appears (if configured)
- ✅ Notifications permission request (if Firebase configured)

---

## Troubleshooting

### Build Errors

**"No signing certificate"**
- Ensure your Apple Developer account is active
- Select your Team in Xcode → Signing & Capabilities

**"Module not found"**
- Clean build folder (⌘⇧K)
- Close and reopen workspace

**"AppConfiguration error"**
- Verify all keys in AppConfiguration.swift
- Check Supabase URL and anon key

### Runtime Errors

**Sign-in doesn't work**
- Verify Supabase Auth providers are enabled
- Check Google Client IDs in Info.plist and Supabase

**Subscriptions don't load**
- Verify RevenueCat API keys
- Check StoreKit configuration file
- Ensure products exist in App Store Connect

---

## What's Next?

### Development Guides

Learn how to build features:

- [Navigation](./guides/NAVIGATION.md) - Add new screens
- [Events](./guides/EVENTS.md) - Cross-module communication
- [Repositories](./guides/REPOSITORIES.md) - Data layer patterns
- [File Uploads](./guides/FILE_UPLOADS.md) - Upload to Supabase storage
- [Notifications](./guides/NOTIFICATIONS.md) - Permission handling
- [Tabs](./guides/TABS.md) - Add tabs to TabView
- [Dependency Injection](./guides/DEPENDENCY_INJECTION.md) - DI patterns

### Deployment

Ready to ship? See:

- [Deployment Guide](./DEPLOYMENT.md) - TestFlight and App Store submission
- [Troubleshooting](./TROUBLESHOOTING.md) - Common issues and fixes

---

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/yourusername/ios-starter-kit/issues)
- **Troubleshooting**: [Troubleshooting Guide](./TROUBLESHOOTING.md)
- **Contributing**: [Contributing Guide](./CONTRIBUTING.md)
