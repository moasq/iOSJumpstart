# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of iOS Starter Kit seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### How to Report

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: **security@yourapp.com**

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

Please include the following information in your report:

- Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### What to Expect

- A confirmation of receipt within 48 hours
- Regular updates on the status of your report
- Credit in the security advisory (if desired) once the issue is resolved

## Security Best Practices for Users

When using this starter kit, please follow these security practices:

### 1. Configuration Security

- **Never commit secrets**: The `AppConfiguration.swift` file contains placeholder values. Replace them with your actual credentials but ensure you're using environment-specific keys.
- **Use different keys for environments**: Use separate API keys for development/sandbox and production environments.
- **Rotate keys regularly**: Periodically rotate your API keys and credentials.

### 2. API Keys

| Service | Key Type | Risk Level | Notes |
|---------|----------|------------|-------|
| Supabase | Anon Key | Low | Public key, safe in client code with RLS enabled |
| RevenueCat | Public API Key | Low | Designed for client-side use |
| Google OAuth | Client ID | Low | Public identifier, not a secret |

**Important**: Never expose your Supabase service role key or any server-side secrets in client code.

### 3. Supabase Security

- **Enable Row Level Security (RLS)**: Always enable RLS on all tables
- **Write proper RLS policies**: Ensure users can only access their own data
- **Use the anon key**: Only use the anon/public key in client applications
- **Never use service role key**: The service role key bypasses RLS and should never be in client code

### 4. RevenueCat Security

- **Use public API keys**: Only use the public API key in the app
- **Validate purchases server-side**: For sensitive entitlement checks, validate on your backend
- **Don't trust client-side entitlement state**: Always verify subscription status server-side for critical features

### 5. Authentication Security

- **Session management**: Sessions are stored securely in the iOS Keychain
- **Token refresh**: Access tokens are automatically refreshed
- **Secure transport**: All API calls use HTTPS

### 6. Data Storage

- **Keychain for secrets**: Tokens and sensitive data are stored in the iOS Keychain
- **SwiftData for local data**: Local persistence uses SwiftData with appropriate data protection

### 7. Third-Party Dependencies

Keep dependencies up to date:

```bash
# Update Swift packages in Xcode
File > Packages > Update to Latest Package Versions
```

Review dependency security advisories regularly.

## Security Checklist Before Launch

Before launching your app to production:

- [ ] Replace all placeholder values in `AppConfiguration.swift`
- [ ] Ensure debug/sandbox keys are only used in DEBUG builds
- [ ] Enable and test Row Level Security policies in Supabase
- [ ] Verify all API calls use HTTPS
- [ ] Remove any debug logging that exposes sensitive data
- [ ] Test authentication flows for security issues
- [ ] Review App Transport Security settings
- [ ] Enable app-specific password/biometric protection if handling sensitive data
- [ ] Implement certificate pinning if required for your use case

## Secure Development Guidelines

When contributing to this project:

1. **Never log sensitive data**: Don't log tokens, passwords, or personal information
2. **Validate all inputs**: Sanitize user inputs before using them
3. **Use parameterized queries**: Prevent SQL injection in database operations
4. **Handle errors securely**: Don't expose stack traces or internal errors to users
5. **Follow least privilege**: Request only necessary permissions and data access

## Contact

For security-related questions that aren't vulnerabilities, you can open a GitHub Discussion.

For vulnerability reports, please email: **security@yourapp.com**
