# Repositories

**Pattern**: Remote-first + local cache

## Using ProfileRepository

```swift
@LazyInjected(\.profileRepository) private var profileRepository

// Get profile (remote-first, falls back to cache)
let profile = try await profileRepository.getProfile()

// Update profile
let request = UpdateProfileRequest(
    displayName: "John Doe",
    avatarURL: URL(string: "https://example.com/avatar.jpg")
)
let updated = try await profileRepository.updateProfile(request: request)

// Force refresh from server
let fresh = try await profileRepository.forceRefresh()
```

## How It Works

```swift
func getProfile() async throws -> ProfileEntity {
    do {
        // 1. Try remote first
        let profile = try await remoteDataSource.getProfile()

        // 2. Cache locally
        try await localDataSource?.saveProfile(profile)

        return profile
    } catch {
        // 3. Fallback to cache if remote fails
        if let cachedProfile = try await localDataSource?.getProfile(for: userId) {
            return cachedProfile
        }
        throw error
    }
}
```

## Creating Custom Repository

### 1. Define Entity

```swift
struct TaskEntity: Identifiable, Codable {
    let id: UUID
    let title: String
    let isCompleted: Bool
}
```

### 2. Define Protocol

```swift
protocol TaskRepository {
    func getTasks() async throws -> [TaskEntity]
    func createTask(_ task: TaskEntity) async throws -> TaskEntity
}
```

### 3. Implement Service

```swift
final class TaskService: TaskRepository {
    private let remoteDataSource: SupabaseTaskDataSource

    func getTasks() async throws -> [TaskEntity] {
        do {
            let tasks = try await remoteDataSource.getTasks()
            // Cache if needed
            return tasks
        } catch {
            // Fallback to cache if available
            throw error
        }
    }
}
```

### 4. Register with DI

```swift
extension Container {
    var taskRepository: Factory<TaskRepository> {
        Factory(self) {
            TaskService(remoteDataSource: SupabaseTaskDataSource(
                client: self.supabaseClient()
            ))
        }
        .singleton
    }
}
```

### 5. Use in ViewModel

```swift
@LazyInjected(\.taskRepository) private var taskRepository

func loadTasks() async {
    tasks = try await taskRepository.getTasks()
}
```

**Reference**: `Src/Features/Repositories/Repositories/Mods/UserProfile/Service/ProfileService.swift`

**Usage**: `Src/iOSJumpstart/iOSJumpstart/App/Tabs/More/View/Profile/MyProfileViewModel.swift:80-120`
