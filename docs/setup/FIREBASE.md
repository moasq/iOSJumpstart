# Firebase Setup (Optional)

**Time**: 8 min | **For**: Push notifications

## 1. Create Firebase Project

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click **Create a project**
3. Enter project name → Enable Google Analytics (optional) → **Create**

## 2. Add iOS App

1. Click **iOS** icon
2. Fill in:
   - **Bundle ID**: `com.yourname.iosstarter` (must match Xcode!)
   - **App nickname**: `iOS Starter Kit`
3. Click **Register app**

## 3. Download & Add Config File

1. Click **Download GoogleService-Info.plist**
2. In Xcode: Right-click `iOSJumpstart/iOSJumpstart/` → **Add Files...**
3. Select the file → Check **Copy items if needed** → **Add**

Verify it's at: `Src/iOSJumpstart/iOSJumpstart/GoogleService-Info.plist`

## 4. Upload APNs Key

1. Go to Apple Developer → **Certificates, Identifiers & Profiles** → **Keys**
2. Click **(+)** → Name it `APNs Key` → Enable **Apple Push Notifications service (APNs)**
3. Click **Continue** → **Register** → **Download** the `.p8` file
4. Save the **Key ID** shown on screen

In Firebase Console:
1. Go to **Project Settings** → **Cloud Messaging**
2. Under **Apple app configuration** → Upload your **APNs Authentication Key**:
   - Upload the `.p8` file
   - Enter **Key ID**
   - Enter **Team ID** (from Apple Developer account page)
3. Click **Upload**

## ✅ Checklist

- [ ] Firebase project created
- [ ] iOS app registered with correct Bundle ID
- [ ] GoogleService-Info.plist added to Xcode
- [ ] APNs key uploaded to Firebase

## Next Step

→ [Set up Google OAuth](./GOOGLE_OAUTH.md)
