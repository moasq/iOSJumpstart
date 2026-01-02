# Google OAuth Setup

**Time**: 10 min

## 1. Create Google Cloud Project

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Click **Select a project** → **New Project**
3. Name it `Your App Name` → **Create**

## 2. Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. Select **External** → **Create**
3. Fill in:
   - **App name**: Your App Name
   - **User support email**: Your email
   - **Developer contact**: Your email
4. Click **Save and Continue** (skip scopes)
5. Add test users (your Gmail) → **Save and Continue**

## 3. Create iOS Client ID

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. **Application type**: **iOS**
4. **Name**: `iOS Client`
5. **Bundle ID**: `com.yourname.iosstarter`
6. Click **Create**

**📋 Save the iOS Client ID**: `123456789-abc...apps.googleusercontent.com`

## 4. Create Web Client ID (for Supabase)

1. Click **Create Credentials** → **OAuth client ID** again
2. **Application type**: **Web application**
3. **Name**: `Web Client (Supabase)`
4. Leave redirect URIs blank for now → **Create**

**📋 Save**:
- Client ID: `987654321-xyz...apps.googleusercontent.com`
- Client Secret: `GOCSPX-abc123...`

## 5. Configure Info.plist

In Xcode, open `iOSJumpstart/iOSJumpstart/Info.plist`:

Find `<key>GIDClientID</key>` and update:

```xml
<key>GIDClientID</key>
<string>YOUR-IOS-CLIENT-ID-HERE.apps.googleusercontent.com</string>
```

## 6. Connect to Supabase

1. Go to [app.supabase.com](https://app.supabase.com) → Your project
2. **Authentication** → **Providers** → **Google**
3. Toggle **Enable** → Fill in:
   - **Client ID**: Your Web Client ID
   - **Client Secret**: Your Web Client Secret
4. Copy the **Redirect URL** shown (e.g., `https://yourproject.supabase.co/auth/v1/callback`)
5. Click **Save**

## 7. Add Redirect URL to Google

1. Back in Google Cloud Console → **Credentials**
2. Click your **Web Client** credential
3. Under **Authorized redirect URIs** → **Add URI**
4. Paste the Supabase redirect URL
5. Click **Save**

## ✅ Checklist

- [ ] Google Cloud project created
- [ ] OAuth consent screen configured
- [ ] iOS Client ID created
- [ ] Web Client ID created
- [ ] Info.plist updated with iOS Client ID
- [ ] Supabase connected with Web credentials
- [ ] Redirect URL added to Google Cloud

## Next Step

→ [Set up RevenueCat](../REVENUECAT_SETUP_GUIDE.md)
