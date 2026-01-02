# Contributing Guide

Thank you for considering contributing to the iOS Starter Kit! This guide will help you get started.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Code Style](#code-style)
- [Project Structure](#project-structure)
- [Commit Conventions](#commit-conventions)
- [Pull Request Process](#pull-request-process)
- [Adding New Features](#adding-new-features)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)

---

## Getting Started

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:

```bash
git clone https://github.com/YOUR_USERNAME/ios-starter-kit.git
cd ios-starter-kit
```

3. Add the upstream repository:

```bash
git remote add upstream https://github.com/ORIGINAL_OWNER/ios-starter-kit.git
```

4. Create a feature branch:

```bash
git checkout -b feature/your-feature-name
```

### Development Setup

1. Open the workspace in Xcode:

```bash
open iOSJumpstart.xcworkspace
```

2. Configure your credentials for testing:

Open `Src/Features/Common/Common/Configuration/AppConfiguration.swift` and fill in your test credentials. See the [README](./README.md#2%EF%B8%8F%E2%83%A3-configure-your-credentials) for where to get each credential.

3. Build the project to ensure everything works:

```bash
# In Xcode: Product → Build (⌘B)
```

---

## Code Style

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) with some additions:

#### Naming Conventions

**Files**:
- ViewModels: `*ViewModel.swift` (e.g., `AuthenticationViewModel.swift`)
- Views: `*View.swift` or `*Page.swift` (e.g., `ProfileView.swift`, `AuthenticationPage.swift`)
- Repositories: `*Repository.swift` (e.g., `ProfileRepository.swift`)
- Services: `*Service.swift` (e.g., `RevenueCatService.swift`)
- Coordinators: `*Coordinator.swift` (e.g., `AuthCoordinator.swift`)

**Code**:
```swift
// ✅ Good
class AuthenticationViewModel: ObservableObject {
    @Published var authState: Loadable<AuthModel> = .notInitiated

    func signInWithApple() async throws { }
}

// ❌ Bad
class AuthVM: ObservableObject {
    @Published var state: Loadable<AuthModel> = .notInitiated

    func appleSignIn() async throws { }
}
```

#### File Organization

**Standard structure for Swift files**:

```swift
//
//  FileName.swift
//  ModuleName
//
//  Purpose: Brief description of what this file does
//

import Foundation
import SwiftUI
// Other imports...

// MARK: - Main Type

public final class MyClass {
    // MARK: - Properties

    // Public properties first
    public var publicProperty: String

    // Private properties after
    private var privateProperty: Int

    // MARK: - Initialization

    public init() { }

    // MARK: - Public Methods

    public func publicMethod() { }

    // MARK: - Private Methods

    private func privateMethod() { }
}

// MARK: - Extensions

extension MyClass {
    // Extension methods
}
```

#### Visibility Rules

Follow these visibility guidelines for feature modules:

| Layer | Access Level | Contains |
|-------|-------------|----------|
| **Core/** | `public` | Entities, Errors, Repository protocols |
| **Service/** | `public` | Service classes that orchestrate data |
| **Data/** | `internal` | DTOs, Data sources, Implementations |
| **View/** | `public` | SwiftUI views, ViewModels |

**Example**:

```swift
// Core/Models/UserEntity.swift (public)
public struct UserEntity {
    public let id: String
    public let email: String

    public init(id: String, email: String) {
        self.id = id
        self.email = email
    }
}

// Data/Models/UserDto.swift (internal)
struct UserDto: Codable {
    let id: String
    let email: String

    func toEntity() -> UserEntity {
        UserEntity(id: id, email: email)
    }
}
```

---

## Project Structure

### Feature Module Structure

When creating a new feature module, follow this structure:

```
Src/Features/YourFeature/
├── YourFeature/                      # Main framework
│   ├── Core/                         # Business logic (public)
│   │   ├── YourFeatureRepository.swift
│   │   ├── Models/
│   │   │   ├── YourFeatureEntity.swift
│   │   │   └── YourFeatureError.swift
│   │   └── Protocols/
│   ├── Data/                         # Data layer (internal)
│   │   ├── Models/
│   │   │   └── YourFeatureDto.swift
│   │   └── Repository/
│   │       └── YourFeatureRepositoryImpl.swift
│   ├── View/                         # UI layer (public)
│   │   ├── YourFeatureView.swift
│   │   └── YourFeatureViewModel.swift
│   └── YourFeatureFactory.swift      # DI registration
└── YourFeatureTests/                 # Tests
    └── YourFeatureTests.swift
```

### Dependency Injection Pattern

Use Factory for dependency injection:

```swift
// In YourFeatureFactory.swift
import Factory

public extension Container {
    var yourFeatureRepository: Factory<YourFeatureRepository> {
        self { YourFeatureRepositoryImpl() }
    }

    var yourFeatureService: Factory<YourFeatureService> {
        self { YourFeatureService() }
            .scope(.shared)  // or .singleton for single instance
    }
}
```

---

## Commit Conventions

We use [Conventional Commits](https://www.conventionalcommits.org/) for clear commit history.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add Google Sign-In support` |
| `fix` | Bug fix | `fix(subscription): correct trial eligibility check` |
| `refactor` | Code refactoring | `refactor(events): simplify event emission logic` |
| `docs` | Documentation | `docs: update SETUP.md with Firebase config` |
| `test` | Add/update tests | `test(auth): add unit tests for AuthRepository` |
| `chore` | Maintenance | `chore: update dependencies to latest versions` |
| `style` | Code style changes | `style: format code with SwiftFormat` |
| `perf` | Performance improvement | `perf(network): optimize image loading` |

### Examples

**Good commits**:

```bash
feat(onboarding): add personalization page with dark mode toggle

- Add PersonalizePage.swift with theme selection
- Integrate with AppStorage for persistence
- Add haptic feedback on selection

Closes #123

---

fix(auth): resolve keychain access error on iOS 18

The keychain query was missing kSecUseDataProtectionKeychain flag,
causing access errors on iOS 18+.

Fixes #456
```

**Bad commits**:

```bash
# ❌ Too vague
Update stuff

# ❌ No type or scope
Added new feature

# ❌ Not descriptive
Fix bug
```

---

## Pull Request Process

### Before Submitting

1. **Update from main**:

```bash
git fetch upstream
git rebase upstream/main
```

2. **Run tests** (if available):

```bash
# In Xcode: Product → Test (⌘U)
```

3. **Build without errors**:

```bash
# In Xcode: Product → Build (⌘B)
```

4. **Update documentation** if needed

### Creating a Pull Request

1. Push your branch to your fork:

```bash
git push origin feature/your-feature-name
```

2. Open a Pull Request on GitHub

3. Fill out the PR template:

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe how you tested this:
- [ ] Tested on iOS 18 simulator
- [ ] Tested on physical device
- [ ] Added unit tests

## Screenshots (if applicable)
Add screenshots showing the changes.

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-reviewed my code
- [ ] Commented complex code sections
- [ ] Updated documentation
- [ ] No new warnings
- [ ] Added tests (if applicable)
```

### Review Process

- PRs require at least one approval
- Address review comments
- Keep the PR focused (one feature/fix per PR)
- Squash commits if requested

---

## Adding New Features

### Step-by-Step Guide

#### 1. Plan Your Feature

Before coding, define:
- What problem does this solve?
- What are the requirements?
- How will it integrate with existing code?
- Does it need backend changes?

#### 2. Create Feature Module

```bash
# Create directory structure
mkdir -p Src/Features/YourFeature/YourFeature/Core/Models
mkdir -p Src/Features/YourFeature/YourFeature/Data/Repository
mkdir -p Src/Features/YourFeature/YourFeature/View
mkdir -p Src/Features/YourFeature/YourFeatureTests
```

#### 3. Define Core Layer

**Entity**:

```swift
// Core/Models/YourFeatureEntity.swift
public struct YourFeatureEntity: Sendable, Equatable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
```

**Error**:

```swift
// Core/Models/YourFeatureError.swift
public enum YourFeatureError: Error, LocalizedError {
    case notFound
    case networkError(Error)

    public var errorDescription: String? {
        switch self {
        case .notFound: return "Item not found"
        case .networkError(let error): return error.localizedDescription
        }
    }
}
```

**Repository Protocol**:

```swift
// Core/YourFeatureRepository.swift
public protocol YourFeatureRepository: Sendable {
    func fetchItems() async throws -> [YourFeatureEntity]
    func fetchItem(id: String) async throws -> YourFeatureEntity
}
```

#### 4. Implement Data Layer

```swift
// Data/Repository/YourFeatureRepositoryImpl.swift
final class YourFeatureRepositoryImpl: YourFeatureRepository {
    @Injected(\.supabaseClient) private var supabase

    func fetchItems() async throws -> [YourFeatureEntity] {
        // Implementation
    }
}
```

#### 5. Create View Layer

**ViewModel**:

```swift
// View/YourFeatureViewModel.swift
@MainActor
final class YourFeatureViewModel: ObservableObject {
    @Published var items: Loadable<[YourFeatureEntity]> = .notInitiated
    @LazyInjected(\.yourFeatureRepository) private var repository

    func loadItems() async {
        items = .loading(existing: items.value)
        do {
            let result = try await repository.fetchItems()
            items = .success(result)
        } catch {
            items = .failure(error)
        }
    }
}
```

**View**:

```swift
// View/YourFeatureView.swift
public struct YourFeatureView: View {
    @StateObject private var viewModel = YourFeatureViewModel()

    public var body: some View {
        List {
            // UI implementation
        }
        .task {
            await viewModel.loadItems()
        }
    }
}
```

#### 6. Register in Factory

```swift
// YourFeatureFactory.swift
import Factory

public extension Container {
    var yourFeatureRepository: Factory<YourFeatureRepository> {
        self { YourFeatureRepositoryImpl() }
    }
}
```

#### 7. Add to Main App

Navigate to your feature from the app:

```swift
// In MainTabView.swift or appropriate location
NavigationLink("Your Feature") {
    YourFeatureView()
}
```

#### 8. Write Tests

```swift
// YourFeatureTests/YourFeatureTests.swift
final class YourFeatureTests: XCTestCase {
    func testFetchItems() async throws {
        // Setup mock
        Container.shared.yourFeatureRepository.register {
            MockYourFeatureRepository()
        }

        let repository = Container.shared.yourFeatureRepository()
        let items = try await repository.fetchItems()

        XCTAssertFalse(items.isEmpty)
    }
}
```

#### 9. Update Documentation

Add your feature to:
- `README.md` (Features section)
- `ARCHITECTURE.md` (Module Breakdown)
- Update screenshots if needed

---

## Testing Guidelines

### Unit Test Requirements

- All new business logic should have unit tests
- Repositories should be tested with mocks
- ViewModels should be tested for state transitions

### Test Naming Convention

```swift
func test_methodName_condition_expectedResult() async throws {
    // Arrange
    let sut = SystemUnderTest()

    // Act
    let result = try await sut.performAction()

    // Assert
    XCTAssertEqual(result, expectedValue)
}
```

**Examples**:

```swift
func test_signIn_withValidCredentials_returnsUser() async throws { }
func test_signIn_withInvalidCredentials_throwsError() async throws { }
func test_loadProfile_whenNotAuthenticated_throwsAuthError() async throws { }
```

### Mocking with Factory

```swift
class MockAuthRepository: AuthRepository {
    var shouldSucceed = true

    func signInWithApple() async throws -> AuthModel {
        if shouldSucceed {
            return AuthModel(id: "test", email: "test@example.com")
        } else {
            throw AuthError.invalidCredentials
        }
    }
}

// In test
override func setUp() {
    super.setUp()
    Container.shared.authRepository.register { MockAuthRepository() }
}
```

### Async Testing

```swift
func testAsyncOperation() async throws {
    let expectation = XCTestExpectation(description: "Async operation completes")

    Task {
        await performAsyncOperation()
        expectation.fulfill()
    }

    await fulfillment(of: [expectation], timeout: 5.0)
}
```

---

## Documentation

### When to Update Documentation

Update documentation when:
- Adding a new feature
- Changing architecture patterns
- Modifying setup steps
- Fixing common issues

### Documentation Files

| File | Update When |
|------|-------------|
| `README.md` | Adding major features, changing tech stack |
| `SETUP.md` | Changing setup process, new service integrations |
| `ARCHITECTURE.md` | Adding modules, changing patterns |
| `TROUBLESHOOTING.md` | Discovering new common issues |
| `DEPLOYMENT.md` | Changing deployment process |

### Inline Documentation

Use documentation comments for public APIs:

```swift
/// Authenticates user with Apple Sign-In.
///
/// This method presents the native Apple Sign-In sheet and exchanges
/// the received ID token with Supabase for a session.
///
/// - Throws: `AuthError.userCancelled` if user dismisses the sheet
/// - Throws: `AuthError.invalidCredentials` if token exchange fails
/// - Returns: Authenticated user model
public func signInWithApple() async throws -> AuthModel {
    // Implementation
}
```

---

## Code Review Checklist

Before requesting review, ensure:

### Code Quality
- [ ] Code follows Swift style guidelines
- [ ] No force unwrapping (`!`) unless absolutely necessary
- [ ] Proper error handling (no ignored errors)
- [ ] No hardcoded values (use constants or configuration)
- [ ] Comments explain "why", not "what"

### Architecture
- [ ] Follows MVVM pattern
- [ ] Proper separation of concerns (View/ViewModel/Repository)
- [ ] Uses dependency injection (Factory)
- [ ] Public/internal visibility correctly applied

### Testing
- [ ] Unit tests added for new logic
- [ ] Tests are meaningful (not just for coverage)
- [ ] Tests follow naming convention

### Documentation
- [ ] Public APIs documented
- [ ] README updated if needed
- [ ] Complex logic commented

### Performance
- [ ] No unnecessary `@Published` properties
- [ ] Async/await used correctly
- [ ] No blocking calls on main thread

---

## Getting Help

- 📖 Review existing code for patterns
- 💬 Open a discussion for questions
- 🐛 Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- 📧 Email: dev@yourproject.com

---

## Thank You!

Your contributions make this project better for everyone. We appreciate your time and effort! 🎉

**Happy coding!** 🚀
