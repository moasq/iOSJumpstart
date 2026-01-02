# Dependency Injection

**Pattern**: Factory with @Injected and @LazyInjected

## Quick Start

```swift
// Eager injection (resolved immediately)
@Injected(\.eventViewModel) private var eventViewModel

// Lazy injection (resolved on first access)
@LazyInjected(\.profileRepository) private var profileRepository
```

## When to Use Which

- **@Injected**: Lightweight objects, services needed immediately, ObservableObjects in views
- **@LazyInjected**: Heavy objects (repositories, network clients), ViewModels, objects you might not need

## Available Dependencies

```swift
// Services
@Injected(\.eventViewModel) private var eventViewModel
@Injected(\.subscriptionManager) private var subscriptionManager
@Injected(\.notificationService) private var notificationService

// Repositories
@LazyInjected(\.profileRepository) private var profileRepository
@LazyInjected(\.authStatusRepository) private var authRepository

// Factories
@LazyInjected(\.fileServiceProvider) private var fileService
```

## Creating Custom Dependencies

### 1. Define Protocol

```swift
protocol WeatherService {
    func getCurrentWeather() async throws -> Weather
}
```

### 2. Implement Service

```swift
final class OpenWeatherService: WeatherService {
    func getCurrentWeather() async throws -> Weather {
        // Implementation
    }
}
```

### 3. Register with Factory

Create or extend a Factory file:

```swift
import Factory

extension Container {
    var weatherService: Factory<WeatherService> {
        Factory(self) {
            OpenWeatherService(apiKey: "YOUR_API_KEY")
        }
        .singleton
    }
}
```

### 4. Use It

```swift
@LazyInjected(\.weatherService) private var weatherService

func loadWeather() async {
    let weather = try await weatherService.getCurrentWeather()
}
```

## Scopes

```swift
.singleton     // Created once, shared across app
.shared        // New instance per scope
.unique        // New instance each time
```

## Testing with Mocks

```swift
// In tests
override func setUp() {
    super.setUp()
    Container.shared.weatherService.register {
        MockWeatherService()
    }
}
```

**Reference**: Existing factories in `Src/Features/*/Factory/` directories

**Full guide**: [Factory GitHub](https://github.com/hmlongco/Factory)
