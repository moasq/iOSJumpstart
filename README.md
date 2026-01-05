# iOSJumpstart

<div align="center">
  <img src="./docs/images/logo.png" alt="iOS Starter Kit Logo" width="200"/>
  <p><strong>Production-ready iOS boilerplate with authentication, payments, and infrastructure pre-configured</strong></p>

  ![iOS 18+](https://img.shields.io/badge/iOS-18%2B-blue)
  ![Swift 6.0+](https://img.shields.io/badge/Swift-6.0%2B-orange)
  ![Xcode 16+](https://img.shields.io/badge/Xcode-16%2B-blue)
  ![License](https://img.shields.io/badge/License-MIT-green)
  ![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey)
</div>

---

## Why This Starter Kit?

Building a production-ready iOS app from scratch involves countless hours of infrastructure setup before you can focus on your unique features. This starter kit eliminates that burden.

### The Problem: Time Sink

| Task | Typical Time | What You're Building |
|------|--------------|----------------------|
| **Authentication** (Apple ID + Google) | 50+ hours | Sign-in UI, session management, token refresh, keychain storage |
| **Payments** (In-App Purchases) | 30+ hours | StoreKit 2, subscription tracking, restore purchases, receipt validation |
| **Backend Setup** (Database + Auth) | 20+ hours | Supabase configuration, RLS policies, database schema, storage buckets |
| **Push Notifications** | 15+ hours | APNs setup, Firebase integration, permission handling |
| **Infrastructure** | 15+ hours | Network monitoring, deep links, app update checking |
| **Architecture Decisions** | 20+ hours | State management, modular structure, dependency injection |
| **Total** | **150+ hours** | 🚫 **Zero business value** |

### The Solution: This Kit

| Before (Without Kit) | After (With Kit) |
|----------------------|-------------------|
| 150+ hours of setup | **30 minutes** ✅ |
| Figuring out best practices | **Production patterns** included ✅ |
| Piecing together auth flows | **Apple ID + Google** ready ✅ |
| Building payment infrastructure | **RevenueCat** integrated ✅ |
| Setting up backend | **Supabase** pre-configured ✅ |
| Architecting from scratch | **Modular, scalable** architecture ✅ |

**Result**: Start building features that matter on **Day 1**, not Day 30.

---

## Technology Stack

| Technology | Purpose | Documentation |
|------------|---------|---------------|
| ![SwiftUI](https://img.shields.io/badge/SwiftUI-000000?logo=swift&logoColor=white) | UI Framework | Native Apple framework |
| ![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?logo=supabase&logoColor=white) | Backend, Auth, Database | [Setup Guide](./docs/SUPABASE_SETUP_GUIDE.md) |
| ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black) | Push Notifications | [Firebase Docs](https://firebase.google.com/docs) |
| ![RevenueCat](https://img.shields.io/badge/RevenueCat-5B5FF9?logo=revenue&logoColor=white) | Subscriptions & Payments | [Setup Guide](./docs/REVENUECAT_SETUP_GUIDE.md) |
| **Factory** | Dependency Injection | Protocol-based DI container |
| **SwiftData** | Local Persistence | iOS 17+ native persistence |

---

## Demo

<div align="center">

### 📺 Watch the Full Demo

See the complete app in action - onboarding, authentication, subscriptions, and all features:

**[▶️ Watch Demo Video](https://streamable.com/venod4)**

*Includes: Onboarding flow, Apple Sign-In, Google OAuth, Subscription paywall, Profile management, and more*

</div>

---

## Quick Start

### Prerequisites

- **macOS** with Xcode 16+ installed
- **Apple Developer Account** ($99/year)
- **30 minutes** for setup

### Setup in 3 Steps

#### 1️⃣ Clone and Configure

```bash
git clone https://github.com/yourusername/ios-starter-kit.git
cd ios-starter-kit
open iOSJumpstart.xcworkspace
```

#### 2️⃣ Configure Your Credentials

Open `Src/Features/Common/Common/Configuration/AppConfiguration.swift` and replace the placeholder values with your actual credentials:

| Placeholder | Where to Get It |
|-------------|-----------------|
| `YOUR_SUPABASE_URL` | [Supabase Dashboard](https://supabase.com/dashboard) → Project Settings → API |
| `YOUR_SUPABASE_ANON_KEY` | [Supabase Dashboard](https://supabase.com/dashboard) → Project Settings → API |
| `YOUR_GOOGLE_CLIENT_ID` | [Google Cloud Console](https://console.cloud.google.com/apis/credentials) |
| `YOUR_REVENUECAT_API_KEY` | [RevenueCat Dashboard](https://app.revenuecat.com/) → Project → API Keys |
| `YOUR_APP_STORE_ID` | [App Store Connect](https://appstoreconnect.apple.com) → App → App Information |

> **Important**: See [SECURITY.md](./SECURITY.md) for security best practices when handling credentials.

#### 3️⃣ Build and Run

```bash
# In Xcode:
# 1. Select your team in Signing & Capabilities
# 2. Update Bundle Identifier
# 3. Product → Build (⌘B)
# 4. Product → Run (⌘R)
```

**That's it!** Your app is running with full authentication, payments, and backend ready.

**[Complete Setup Guide →](./docs/SETUP.md)**

---

## Requirements

- **macOS** 13.0 or later
- **Xcode** 16.0 or later
- **iOS** 18.0 or later (deployment target)
- **Swift** 6.0 or later
- **Apple Developer Account** ($99/year)

---

## Documentation

Comprehensive guides for every aspect of the starter kit:

### Setup Guides
| Guide | Description |
|-------|-------------|
| 📖 **[Complete Setup](./docs/SETUP.md)** | Main setup orchestrator - start here |
| 🍎 **[Apple Developer](./docs/setup/APPLE_DEVELOPER.md)** | App ID, capabilities, App Store Connect |
| ⚙️ **[Xcode Config](./docs/setup/XCODE_CONFIG.md)** | Bundle ID, signing, capabilities |
| 🔧 **[App Configuration](./docs/setup/APP_CONFIGURATION.md)** | API keys and settings |
| 🗄️ **[Supabase](./docs/SUPABASE_SETUP_GUIDE.md)** | Database, auth, storage |
| 💰 **[RevenueCat](./docs/REVENUECAT_SETUP_GUIDE.md)** | Subscriptions and payments |

### Development Guides
| Guide | Description |
|-------|-------------|
| 🧭 **[Navigation](./docs/guides/NAVIGATION.md)** | Adding screens and routes |
| 📂 **[Tabs](./docs/guides/TABS.md)** | Adding tabs to TabView |
| 📤 **[File Uploads](./docs/guides/FILE_UPLOADS.md)** | Uploading to Supabase storage |

### Reference Documentation
| Guide | Description |
|-------|-------------|
| 🏗️ **[Architecture](./docs/reference/ARCHITECTURE.md)** | Technical patterns and design |
| 🔗 **[Deep Linking](./docs/reference/DEEP_LINKING.md)** | Deep link architecture |
| 🚀 **[Deployment](./docs/DEPLOYMENT.md)** | TestFlight and App Store |
| 🤝 **[Contributing](./CONTRIBUTING.md)** | Contributing guidelines |
| 🔒 **[Security](./SECURITY.md)** | Security policy and best practices |
| 🛠️ **[Troubleshooting](./docs/TROUBLESHOOTING.md)** | Common issues and solutions |

---

## Customization

This is a **template**, not a framework. You own the code and can customize everything:

### 🎨 Branding
- Update app icon in `Assets.xcassets`
- Modify colors in `Common/Colors.xcassets`
- Replace fonts (currently Poppins)
- Update onboarding content

### 🔧 Features
- Add new feature modules in `Src/Features/`
- Remove unused modules (e.g., Subscription if you don't need it)
- Extend existing services
- Add custom UI components

### 🗄️ Backend
- Extend database schema in Supabase
- Add new Edge Functions
- Modify RLS policies
- Add new storage buckets

---


### Community

- ⭐ **Star this repo** if it helped you!
- 🍴 **Fork** to create your own version
- 🤝 **Contribute** improvements back to the community

---

## License

This project is licensed under the **MIT License** - see the [LICENSE](./LICENSE) file for details.

---

## Acknowledgments

Built with these amazing tools and services:

### Open Source
- [Supabase](https://supabase.com) - Open source Firebase alternative
- [Factory](https://github.com/hmlongco/Factory) - Dependency injection for Swift

### Commercial Services
- [RevenueCat](https://www.revenuecat.com) - In-app subscriptions made easy
- [Firebase](https://firebase.google.com) - Google's app development platform (SDKs are open source)

---

## What's Next?

Once you've set up the app:

1. ✅ Run through [SETUP.md](./docs/SETUP.md)
2. ✅ Configure your services (Supabase, RevenueCat, Google)
3. ✅ Customize branding and UI
4. ✅ Build your unique features
5. ✅ Deploy to App Store with [DEPLOYMENT.md](./docs/DEPLOYMENT.md)

---

<div align="center">

**Ready to build your iOS app in record time?**

⭐ **Star this repo** | 🍴 **Fork it** | 📖 **[Start Setup →](./docs/SETUP.md)**

Made with ❤️ for iOS developers who want to focus on features, not infrastructure.

</div>
