# App Configuration

**Time**: 5 min | **File**: `Src/Features/Common/Common/Configuration/AppConfiguration.swift`

Add all your API keys and configuration to this central file.

## Configuration File

Open `Src/Features/Common/Common/Configuration/AppConfiguration.swift` and update:

```swift
enum AppConfiguration {
    // MARK: - Supabase
    enum Supabase {
        static let url: String = "https://yourproject.supabase.co"
        static let anonKey: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }

    // MARK: - RevenueCat
    enum RevenueCat {
        #if DEBUG
        static let apiKey: String = "appl_test_ABC123..."
        #else
        static let apiKey: String = "appl_ABC123..."
        #endif

        static let entitlementID = "pro"
    }

    // MARK: - Google OAuth
    enum Google {
        static let clientID = "123456789-abc.apps.googleusercontent.com"
    }

    // MARK: - Deep Linking
    enum DeepLink {
        static let scheme = "iosjumpstart"  // Match your URL scheme
    }
}
```

## Where to Find Values

| Key | Where to Find |
|-----|---------------|
| **Supabase URL** | Supabase Dashboard → Project Settings → API |
| **Supabase Anon Key** | Supabase Dashboard → Project Settings → API → `anon` `public` |
| **RevenueCat Test Key** | RevenueCat Dashboard → API keys → Apple App Store (Sandbox) |
| **RevenueCat Prod Key** | RevenueCat Dashboard → API keys → Apple App Store (Production) |
| **RevenueCat Entitlement** | Your entitlement identifier (e.g., `pro`, `premium`) |
| **Google Client ID** | Google Cloud Console → Credentials → iOS Client ID |
| **Deep Link Scheme** | Your URL scheme from Info.plist (default: `iosjumpstart`) |

## Debug vs Release

The template uses build configurations:
- `#if DEBUG` = Test/development keys
- `#else` = Production keys

**Important**: Always use test keys during development!

## ✅ Checklist

- [ ] Supabase URL and anon key added
- [ ] RevenueCat test and prod keys added
- [ ] RevenueCat entitlement ID set
- [ ] Google Client ID added
- [ ] Deep link scheme matches Info.plist
- [ ] Build succeeds (⌘B)

## Next Step

→ [Build & Verify](../SETUP.md#phase-8-build--verify)
