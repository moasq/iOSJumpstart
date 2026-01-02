# Xcode Configuration

**Time**: 5 min

## 1. Open Project

```bash
open iOSJumpstart.xcworkspace
```

Select `iOSJumpstart` target in Xcode.

## 2. Configure Bundle Identifier

**Targets** → **iOSJumpstart** → **General**

- **Bundle Identifier**: `com.yourname.iosstarter`
  - Must match the Bundle ID from Apple Developer Portal

## 3. Set Up Signing

**Signing & Capabilities** tab:

- **Team**: Select your Apple Developer account
- **Automatically manage signing**: ✅ Enabled

Xcode will auto-generate provisioning profiles.

## 4. Verify Capabilities

Ensure these are enabled:

- ✅ **Sign in with Apple**
- ✅ **Push Notifications**
- ✅ **In-App Purchase**

If missing, click **(+) Capability** and add them.

## 5. Configure URL Schemes

**Info** tab → **URL Types** should have:

```
iosjumpstart
```

This is for deep linking. Already configured in the template.

## ✅ Checklist

- [ ] Bundle Identifier matches Apple Developer Portal
- [ ] Code signing configured with your team
- [ ] Capabilities enabled: Sign in with Apple, Push, In-App Purchase
- [ ] URL scheme exists for deep linking
- [ ] Build succeeds (⌘B)

## Next Step

→ [Set up Supabase](../SUPABASE_SETUP_GUIDE.md)
