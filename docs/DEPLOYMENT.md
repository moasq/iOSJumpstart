# Deployment Guide

Complete guide for deploying your iOS app to TestFlight and the App Store.

---

## Table of Contents

- [Pre-Deployment Checklist](#pre-deployment-checklist)
- [Build Configuration](#build-configuration)
- [Archive and Upload](#archive-and-upload)
- [TestFlight Setup](#testflight-setup)
- [App Store Submission](#app-store-submission)
- [CI/CD with GitHub Actions](#cicd-with-github-actions)
- [Post-Submission](#post-submission)
- [Release Checklist](#release-checklist)

---

## Pre-Deployment Checklist

Before creating your first release, ensure everything is ready:

### Code Readiness

- [ ] All features tested thoroughly
- [ ] No critical bugs remaining
- [ ] Unit tests passing (if applicable)
- [ ] No TODO/FIXME comments in production code
- [ ] Debug logging disabled or removed
- [ ] No test data in production code

### Configuration

- [ ] Production API keys configured in `AppConfiguration.swift`
- [ ] Correct Supabase URL and keys (production, not debug)
- [ ] RevenueCat production API key set
- [ ] App Store ID configured for update checker
- [ ] All service integrations tested

### Assets

- [ ] App icon created and added (all required sizes)
- [ ] Launch screen configured
- [ ] Screenshots prepared (all required device sizes)
- [ ] App preview videos (optional but recommended)

### Legal & Compliance

- [ ] Privacy Policy URL valid and accessible
- [ ] Terms of Service URL valid
- [ ] App complies with App Store Review Guidelines
- [ ] Third-party licenses documented
- [ ] Age rating determined

### App Store Connect

- [ ] App created in App Store Connect
- [ ] All metadata complete (name, subtitle, description, keywords)
- [ ] Support URL configured
- [ ] Marketing URL (if applicable)
- [ ] Demo account credentials prepared (if app requires login)

---

## Build Configuration

### Step 1: Switch to Release Configuration

Release builds are optimized and remove debug features.

**In Xcode:**

1. Click the scheme selector (next to Play/Stop buttons)
2. Click **Edit Scheme...**
3. Select **Run** in the left sidebar
4. **Build Configuration** dropdown → Select **Release**
5. Close

![Scheme Configuration](./images/scheme-configuration-placeholder.png)

### Step 2: Update Version and Build Number

**Version Number** (`CFBundleShortVersionString`):
- Semantic versioning: `MAJOR.MINOR.PATCH`
- Example: `1.0.0` for first release
- Increment for each release:
  - **Major**: Breaking changes (1.0.0 → 2.0.0)
  - **Minor**: New features (1.0.0 → 1.1.0)
  - **Patch**: Bug fixes (1.0.0 → 1.0.1)

**Build Number** (`CFBundleVersion`):
- Integer that increments with each upload
- Example: `1`, `2`, `3`, etc.
- Must be **higher** than previous build for the same version

**Update in Xcode:**

1. Select project → **iOSJumpstart** target → **General**
2. **Identity** section:
   - **Version**: `1.0.0` (or your version)
   - **Build**: `1` (increment for each upload)

Alternatively, edit `Info.plist` directly:

```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### Step 3: Configure Production Credentials

Update `AppConfiguration.swift` with production values:

```swift
public enum Supabase {
    #if DEBUG
    public static let url = "https://debug-project.supabase.co"
    public static let anonKey = "DEBUG_KEY"
    #else
    // Production values (Release builds use this)
    public static let url = "https://prod-project.supabase.co"
    public static let anonKey = "PRODUCTION_KEY"
    #endif
}

public enum RevenueCat {
    #if DEBUG
    public static let apiKey = "test_..."
    #else
    public static let apiKey = "appl_..."  // Production key
    #endif
}
```

**Verify no DEBUG flags in code**:

```bash
# Search for DEBUG flags
grep -r "#if DEBUG" Src/

# Ensure no test/debug code will run in production
```

### Step 4: Disable Debug Features

Ensure these are disabled in Release builds:

1. **Logging**:
```swift
public enum Debug {
    #if DEBUG
    public static let enableLogging = true
    #else
    public static let enableLogging = false  // OFF in production
    #endif
}
```

2. **Skip Onboarding** (if you have a debug flag):
```swift
#if DEBUG
let skipOnboarding = false  // Set to false
#endif
```

3. **RevenueCat Debug Mode**:
```swift
#if DEBUG
Purchases.logLevel = .debug
#else
Purchases.logLevel = .warn  // Minimal logging in production
#endif
```

---

## Archive and Upload

### Step 1: Select Generic iOS Device

**In Xcode:**

1. Click the device selector (next to scheme)
2. Select **Any iOS Device (arm64)**

> **Note**: You cannot archive for a specific simulator or device. Must be "Any iOS Device".

### Step 2: Create Archive

**In Xcode:**

1. **Product** → **Archive**
2. Wait for the archive to complete (5-15 minutes)
3. The **Organizer** window will open automatically

![Archive Process](./images/archive-process-placeholder.png)

**Common Issues**:

- **"Archive is grayed out"**: Ensure "Any iOS Device" is selected
- **Build fails**: Check build errors, ensure all tests pass
- **Signing error**: Verify team is selected in Signing & Capabilities

### Step 3: Validate Archive

Before uploading, validate the archive to catch issues early:

1. In **Organizer**, select your archive
2. Click **Validate App**
3. Select **Automatically manage signing** (recommended)
4. Click **Validate**
5. Wait for validation to complete

**Validation Checks**:
- ✅ Code signing valid
- ✅ Provisioning profiles correct
- ✅ All required capabilities present
- ✅ No invalid frameworks
- ✅ App bundle structure correct

**If validation fails**: Fix the issues and create a new archive.

### Step 4: Upload to App Store Connect

1. In **Organizer**, select your archive
2. Click **Distribute App**
3. Select **App Store Connect** → **Upload**
4. Select **Automatically manage signing**
5. Click **Upload**
6. Wait for upload to complete (5-20 minutes)

You'll receive an email when the build is processed (usually within 30 minutes).

---

## TestFlight Setup

TestFlight allows you to test your app before public release.

### Internal Testing

**For your team (up to 100 testers)**:

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app → **TestFlight** tab
3. Wait for build to finish processing
4. Click on the build number
5. **Test Information** section:
   - **What to Test**: Describe what testers should focus on
   - **Beta App Description**: Optional
6. Add internal testers:
   - **Testers** → **Internal Group** → **+**
   - Add team members by email
7. Click **Save**

Testers receive email invitation immediately.

### External Testing

**For beta testers outside your team (up to 10,000 testers)**:

1. In App Store Connect → TestFlight
2. Select your build
3. Click **Add to External Testing**
4. Create a new group or select existing
5. Add testers by email or public link
6. **Submit for Review** (required for external testing)

**Beta App Review**:
- Required before external testers can access
- Similar to App Store review but faster (24-48 hours)
- Provide:
  - **Beta App Description**
  - **What to Test**
  - **Sign-in credentials** (if app requires login)

### Testing Best Practices

**For Testers**:
1. Install TestFlight app from App Store
2. Accept invitation
3. Install beta build
4. Provide feedback via TestFlight or other channels

**For Developers**:
- Monitor crash reports in App Store Connect
- Respond to feedback quickly
- Iterate based on tester input
- Upload new builds as needed (increment build number)

---

## App Store Submission

### Step 1: Prepare App Store Connect Metadata

All metadata is entered in [App Store Connect](https://appstoreconnect.apple.com):

1. Select your app → **App Information**

### Step 2: App Information

**Name**:
- Display name on App Store
- Maximum 30 characters
- Must be unique

**Subtitle** (Optional but recommended):
- Short description (30 characters)
- Appears below app name
- Example: "Secure & Fast Authentication"

**Privacy Policy URL**:
- Required
- Must be accessible without login
- Example: `https://yourapp.com/privacy`

**Category**:
- **Primary**: Choose most relevant
- **Secondary**: Optional

**Content Rights**:
- Contains third-party content: Yes/No
- If yes, need rights to use it

### Step 3: Pricing and Availability

1. **Price**: Free or paid (set price tier)
2. **Availability**: All countries or specific regions
3. **App Release**: Manual or automatic after approval

### Step 4: App Privacy

**Privacy Details** (Required):

1. **Data Collection**: List all data your app collects
   - User IDs, email, name, etc.
   - Usage data, diagnostics, etc.
2. **Data Usage**: How data is used
   - Analytics, app functionality, advertising, etc.
3. **Data Linking**: Is data linked to user identity?
4. **Tracking**: Does app track users?

Example for this starter kit:
- **Identifiers**: Email, User ID (for account creation)
- **Usage Data**: Analytics (if using Firebase Analytics)
- **Linked to User**: Yes (for authentication)
- **Tracking**: No (unless you added third-party trackers)

### Step 5: App Review Information

**Contact Information**:
- First name, last name
- Phone number
- Email

**Demo Account**:
- **Required** if app requires login
- Provide username and password
- Ensure account has access to all features

**Notes**:
- Describe any special setup required
- Mention non-obvious features
- Explain compliance with guidelines

Example:
```
This app uses Supabase for backend and RevenueCat for subscriptions.
Test account credentials:
- Email: test@example.com
- Password: TestPassword123!

The app requires internet connection for authentication.
Subscription features can be tested using sandbox environment.
```

### Step 6: Version Information

1. **Version**: `1.0.0` (must match your build)
2. **Copyright**: © 2025 Your Company Name
3. **Description** (4000 characters):
   - What the app does
   - Key features
   - Benefits to users
   - **Tip**: Front-load important info (first 170 chars visible in search)

Example description:
```
Build amazing iOS apps faster with our production-ready starter kit.

KEY FEATURES:
• Secure authentication (Apple Sign-In & Google)
• In-app subscriptions with RevenueCat
• Supabase backend integration
• Push notifications
• Network monitoring
• App update checking

INCLUDED:
- Complete authentication flow
- Subscription management
- User profile system
- File upload with compression
- Modern SwiftUI architecture
- Event-driven communication

PERFECT FOR:
Developers who want to skip infrastructure setup and focus on unique features.

TECHNOLOGIES:
- SwiftUI
- Supabase
- RevenueCat
- Firebase
```

4. **Keywords** (100 characters, comma-separated):
   - Choose carefully (impacts search)
   - No spaces around commas
   - No duplicate words

Example:
```
ios,swift,swiftui,starter,boilerplate,template,authentication,subscription,supabase,revenuecat
```

5. **Promotional Text** (170 characters, can be updated without new version):
```
Production-ready iOS template with auth, payments, and backend. Start building features on Day 1!
```

6. **What's New in This Version**:
   - For version 1.0.0:
```
Initial release! Features include:
• Apple Sign-In and Google authentication
• RevenueCat subscription management
• Supabase backend integration
• Push notifications
• Network monitoring
• Multi-page onboarding flow
```

### Step 7: App Screenshots

**Required Sizes**:

| Device | Size | Required |
|--------|------|----------|
| 6.7" Display | 1290 × 2796 | ✅ Yes |
| 6.5" Display | 1242 × 2688 | ✅ Yes |
| 5.5" Display | 1242 × 2208 | ❌ No (but recommended) |
| iPad Pro (3rd gen) 12.9" | 2048 × 2732 | ✅ Yes (if iPad supported) |
| iPad Pro (2nd gen) 12.9" | 2048 × 2732 | ❌ No |

**Best Practices**:
- Show actual app features
- Use device frames
- Add captions explaining features
- First 2-3 screenshots most important (appear in search)
- Maximum 10 screenshots per device size

**Tools**:
- [Shotbot](https://shotbot.io/) - Generate screenshots with frames
- [Screenshots.pro](https://screenshots.pro/) - Professional templates
- [Figma](https://www.figma.com/) - Design custom screenshots

**Upload**:
1. In App Store Connect → Your App → App Store tab
2. **Media** section
3. Drag and drop screenshots for each device size
4. Arrange in desired order

### Step 8: Build Selection

1. In App Store Connect → **App Store** tab
2. Scroll to **Build** section
3. Click **+** to select a build
4. Choose your uploaded build from TestFlight
5. Click **Done**

### Step 9: Age Rating

Answer questionnaire about app content:
- Violence, profanity, horror, sexual content, etc.
- Be honest; incorrect rating can lead to rejection
- Most apps with just authentication: **4+**

### Step 10: Submit for Review

1. Review all sections (look for red exclamation marks)
2. Fix any missing required fields
3. Click **Save** (top right)
4. Click **Submit for Review**
5. Confirm submission

**Review Timeline**:
- Typically 24-48 hours
- Can be longer during holidays or major iOS releases
- Check status in App Store Connect

---

## CI/CD with GitHub Actions

Automate building and testing with GitHub Actions.

### Step 1: Create Workflow File

Create `.github/workflows/ios.yml`:

```yaml
name: iOS CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build-and-test:
    runs-on: macos-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: '15.2'

    - name: Install dependencies
      run: |
        # If using CocoaPods
        # pod install

    - name: Build for testing
      run: |
        xcodebuild clean build-for-testing \
          -workspace iOSJumpstart.xcworkspace \
          -scheme iOSJumpstart \
          -sdk iphonesimulator \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.2'

    - name: Run tests
      run: |
        xcodebuild test-without-building \
          -workspace iOSJumpstart.xcworkspace \
          -scheme iOSJumpstart \
          -sdk iphonesimulator \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.2'
```

### Step 2: Add Secrets

Store sensitive data in GitHub repository secrets:

1. Go to GitHub repository → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**

**Required Secrets**:

- `APPCONFIG_SWIFT`: Base64-encoded `AppConfiguration.swift`
  ```bash
  cat Src/Features/Common/Common/Configuration/AppConfiguration.swift | base64
  ```

- `GOOGLESERVICE_INFO_PLIST`: Base64-encoded `GoogleService-Info.plist`
  ```bash
  cat Src/iOSJumpstart/iOSJumpstart/GoogleService-Info.plist | base64
  ```

### Step 3: Decode Secrets in Workflow

Update workflow to decode secrets:

```yaml
- name: Decode configuration files
  env:
    APPCONFIG_SWIFT: ${{ secrets.APPCONFIG_SWIFT }}
    GOOGLESERVICE_INFO_PLIST: ${{ secrets.GOOGLESERVICE_INFO_PLIST }}
  run: |
    echo "$APPCONFIG_SWIFT" | base64 --decode > \
      Src/Features/Common/Common/Configuration/AppConfiguration.swift

    echo "$GOOGLESERVICE_INFO_PLIST" | base64 --decode > \
      Src/iOSJumpstart/iOSJumpstart/GoogleService-Info.plist
```

### Step 4: Advanced: Auto-Deploy to TestFlight

Use [Fastlane](https://fastlane.tools/) for automated deployment:

1. **Install Fastlane**:
```bash
brew install fastlane
cd your_project_directory
fastlane init
```

2. **Configure Fastfile**:

```ruby
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    increment_build_number(xcodeproj: "Src/iOSJumpstart/iOSJumpstart.xcodeproj")
    build_app(workspace: "iOSJumpstart.xcworkspace", scheme: "iOSJumpstart")
    upload_to_testflight(skip_waiting_for_build_processing: true)
  end
end
```

3. **Add to GitHub Actions**:

```yaml
- name: Deploy to TestFlight
  env:
    APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
  run: |
    fastlane beta
```

---

## Post-Submission

### Monitor Review Status

**Check status**:
1. App Store Connect → Your App → **App Store** tab
2. Status shows:
   - **Waiting for Review**: In queue
   - **In Review**: Apple is reviewing
   - **Rejected**: Issues found (see Resolution Center)
   - **Pending Developer Release**: Approved, awaiting your release
   - **Ready for Sale**: Live on App Store

**Respond to App Review**:
- Check **Resolution Center** for messages
- Respond within **24 hours** to avoid delays
- Provide requested information or clarifications

### Common Rejection Reasons

1. **Incomplete Information**:
   - Missing demo account credentials
   - Broken privacy policy URL
   - Unclear app description

2. **Guideline Violations**:
   - App crashes on launch
   - Features don't work as described
   - Missing required disclosures

3. **Design Issues**:
   - Placeholder content
   - Confusing user interface
   - Poor user experience

**If Rejected**:
1. Read rejection message carefully
2. Fix the issues
3. Reply in Resolution Center (if clarification needed)
4. Upload new build (if code changes required)
5. Resubmit

### After Approval

**Manual Release**:
1. App Store Connect → Your App → **Pricing and Availability**
2. Click **Release this version**

**Automatic Release**:
- Configured during submission
- App goes live immediately after approval

### Monitor Performance

**In App Store Connect**:
- **App Analytics**: Downloads, sales, crashes
- **Ratings and Reviews**: User feedback
- **Crash Reports**: Diagnose issues

**In RevenueCat Dashboard**:
- Subscription metrics
- Revenue tracking
- Trial conversions

**In Supabase Dashboard**:
- User sign-ups
- Database usage
- API requests

---

## Release Checklist

Use this checklist for each release:

### Pre-Release
- [ ] All features tested
- [ ] Production credentials configured
- [ ] Version and build number updated
- [ ] Release notes written
- [ ] Screenshots updated (if UI changed)
- [ ] Privacy policy updated (if data collection changed)

### Build & Upload
- [ ] Release configuration selected
- [ ] Archive created successfully
- [ ] Archive validated without errors
- [ ] Uploaded to App Store Connect
- [ ] Build processed (received email)

### TestFlight
- [ ] Internal testing completed
- [ ] Critical bugs fixed
- [ ] External beta testing (optional)
- [ ] Crash reports reviewed

### App Store Connect
- [ ] Metadata reviewed and updated
- [ ] Screenshots current
- [ ] What's New text written
- [ ] Build selected
- [ ] Age rating appropriate
- [ ] Demo account working

### Submission
- [ ] All sections complete (no red marks)
- [ ] Submitted for review
- [ ] Monitoring review status
- [ ] Ready to respond to App Review

### Post-Approval
- [ ] Released to App Store
- [ ] Monitoring crash reports
- [ ] Tracking user feedback
- [ ] Planning next update

---

## Version Management

### Semantic Versioning

Follow [Semantic Versioning](https://semver.org/):

**Format**: `MAJOR.MINOR.PATCH`

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes, major redesign
- **MINOR** (1.0.0 → 1.1.0): New features, backwards compatible
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, no new features

**Examples**:
- First release: `1.0.0`
- Bug fix: `1.0.1`
- New feature: `1.1.0`
- Breaking change: `2.0.0`

### Build Number Strategy

**Auto-increment**:
```bash
# Using agvtool (Apple's versioning tool)
agvtool next-version -all
```

**Manual**:
- Increment for each upload to App Store Connect
- Can reset to 1 for new version numbers
- Example: Version 1.0.0 builds: 1, 2, 3; Version 1.1.0 builds: 1, 2

---

## Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [GitHub Actions for iOS](https://github.com/actions/starter-workflows/blob/main/ci/ios.yml)

---

**Ready to ship?** Follow this guide step-by-step, and you'll have your app on the App Store! 🚀
