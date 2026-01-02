# RevenueCat Setup

**Time**: 10 min | **For**: Subscriptions & In-App Purchases

## 1. Create Account & Get API Key

1. Sign up at [app.revenuecat.com](https://app.revenuecat.com)
2. Create new project
3. Add iOS app:
   - **Bundle ID**: Your app's bundle ID
   - **Store**: **Test Store** (for development)
4. Go to **Project Settings** → **API Keys**
5. Copy API key (starts with `test_`)

**📋 Save**: Test API Key

---

## 2. Create Products

### Add Products in Dashboard

Go to **Products** → **+ New**:

| Product ID | Type | Duration | Price |
|------------|------|----------|-------|
| `premium_monthly` | Subscription | P1M | $9.99 |
| `premium_yearly` | Subscription | P1Y | $79.99 |
| `premium_lifetime` | Non-consumable | - | $199.99 |

### Create Entitlement

1. **Entitlements** → **+ New**
2. Identifier: `premium`
3. **Attach Products** → Select all 3 products

### Create Offering

1. **Offerings** → **+ New**
2. Identifier: `default`
3. Mark as **Current Offering**
4. Add packages:
   - Package: `$rc_monthly` → Product: `premium_monthly`
   - Package: `$rc_annual` → Product: `premium_yearly`
   - Package: `$rc_lifetime` → Product: `premium_lifetime`

### Configure Paywall (Optional)

Click **Configure Paywall** → Choose template → Customize → Save

---

## 3. Update StoreKit Configuration

For local testing in Xcode:

1. Open `Src/iOSJumpstart/iOSJumpstart.storekit`
2. Update product IDs to match Dashboard:
   - `premium_monthly`
   - `premium_yearly`
   - `premium_lifetime`
3. Edit Scheme → Run → Options → StoreKit Configuration: Select `.storekit` file

---

## 4. Test Subscription Flow

1. Run app (⌘R)
2. Navigate to Settings → Tap subscription button
3. Paywall should appear with 3 products
4. Complete test purchase
5. Verify premium badge appears

---

## ✅ Checklist

- [ ] RevenueCat account created
- [ ] API key saved
- [ ] 3 products created in Dashboard
- [ ] Entitlement `premium` created
- [ ] Offering `default` created and marked current
- [ ] StoreKit file updated
- [ ] Test purchase works

**Saved Values**:
```
Test API Key: test_...
Entitlement ID: premium
```

---

## Production Setup

When ready for App Store:

1. Create **App Store** app in RevenueCat (not Test Store)
2. Get production API key (starts with `appl_`)
3. Update `AppConfiguration.swift`:

```swift
enum RevenueCat {
    #if DEBUG
    static let apiKey = "test_ABC123..."
    #else
    static let apiKey = "appl_ABC123..."
    #endif

    static let entitlementID = "premium"
}
```

---

## Troubleshooting

**Products not loading?**
- Verify API key matches project
- Check products attached to entitlement
- Ensure offering marked as "Current"
- Verify StoreKit product IDs match exactly

**Not granting access after purchase?**
- Entitlement ID must be `premium`
- Products must be attached to entitlement
- Check subscription manager logs

---

## Next Step

→ [Add API Keys to App](./setup/APP_CONFIGURATION.md)
