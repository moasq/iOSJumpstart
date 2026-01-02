# Apple Developer Setup

**Time**: 15 min | **Cost**: $99/year

## 1. Enroll in Apple Developer Program

1. Go to [developer.apple.com/programs/enroll](https://developer.apple.com/programs/enroll)
2. Sign in → **Start Your Enrollment**
3. Choose **Individual** or **Organization**
4. Complete $99 payment
5. Wait 24-48 hours for approval email

## 2. Create App ID

1. [developer.apple.com/account](https://developer.apple.com/account) → **Certificates, Identifiers & Profiles**
2. Click **Identifiers** → **(+)** button
3. Select **App IDs** → **App** → **Continue**
4. Fill in:
   - **Description**: `iOS Starter Kit`
   - **Bundle ID**: `com.yourname.iosstarter` (make it unique!)
   - **Capabilities**: Enable ✅ Sign In with Apple, ✅ Push Notifications, ✅ In-App Purchase
5. Click **Continue** → **Register**

**📋 Save your Bundle ID** - you'll need it everywhere!

## 3. Create App in App Store Connect

1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **My Apps**
2. Click **(+)** → **New App**
3. Fill in:
   - **Platform**: iOS
   - **Name**: Your App Name
   - **Bundle ID**: Select from dropdown
   - **SKU**: `YOURAPP_V1`
4. Click **Create**

## 4. Create Subscription Products (Optional)

1. In App Store Connect → **Monetization** → **Subscriptions**
2. Click **Create** subscription group: `Premium Subscriptions`
3. Add products:

| Product | Product ID | Duration | Price |
|---------|-----------|----------|-------|
| Monthly | `com.yourname.iosstarter.monthly` | 1 Month | $9.99 |
| Annual | `com.yourname.iosstarter.annual` | 1 Year | $99.99 |

For each:
- Add localization (display name + description)
- Click **Save**

## ✅ Checklist

- [ ] Apple Developer enrollment approved
- [ ] Bundle ID created with capabilities enabled
- [ ] App Store Connect app created
- [ ] Subscription products created (if monetizing)

**Saved Values**:
```
Bundle ID: com.yourname.iosstarter
```

## Next Step

→ [Configure Xcode](./XCODE_CONFIG.md)
