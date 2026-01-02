# Repositories Module

Data access layer supporting local (SwiftData), remote (Supabase), or both.

---

## Choose Your Case

Pick **one** case based on your needs:

| Case | When to Use |
|------|-------------|
| [Case A: Remote Only](#case-a-remote-only) | Simple apps, always online |
| [Case B: Local Only](#case-b-local-only) | Offline-first, no backend |
| [Case C: Local + Remote](#case-c-local--remote) | Offline support with sync |

---

## Visibility Rules

| Layer | Access | Contains |
|-------|--------|----------|
| **Core/** | `public` | Entity, Error, Repository protocol |
| **Service/** | `public` | Orchestration between local/remote |
| **Remote/** | `internal` | DTOs, RemoteDataSource |
| **Local/** | `internal` | SwiftData models, LocalDataSource |

**Why?** Consumers only need Core and Service. Implementation details stay hidden.

---

# Case A: Remote Only

Use when your app always has network access.

## Step 1: Create Core Layer (public)

Create `Mods/Receipts/Core/` folder:

**ReceiptEntity.swift**
```swift
import Foundation

public struct ReceiptEntity: Sendable, Equatable {
    public let id: String
    public let amount: Decimal
    public let date: Date

    public init(id: String, amount: Decimal, date: Date) {
        self.id = id
        self.amount = amount
        self.date = date
    }
}
```

**ReceiptError.swift**
```swift
import Foundation

public enum ReceiptError: Error, LocalizedError {
    case notFound
    case networkError(Error)
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .notFound: return "Receipt not found"
        case .networkError(let error): return error.localizedDescription
        case .unknown(let error): return error.localizedDescription
        }
    }
}
```

**ReceiptRepository.swift**
```swift
import Foundation

public protocol ReceiptRepository: Sendable {
    func getReceipts() async throws -> [ReceiptEntity]
    func getReceipt(id: String) async throws -> ReceiptEntity
    func createReceipt(amount: Decimal) async throws -> ReceiptEntity
    func deleteReceipt(id: String) async throws
}
```

## Step 2: Create Remote Layer (internal)

Create `Mods/Receipts/Remote/` folder:

**ReceiptDto.swift**
```swift
import Foundation

struct ReceiptDto: Codable {
    let id: String
    let amount: String  // Supabase stores Decimal as String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case createdAt = "created_at"
    }

    func toEntity() -> ReceiptEntity {
        ReceiptEntity(
            id: id,
            amount: Decimal(string: amount) ?? 0,
            date: createdAt
        )
    }
}
```

**ReceiptRemoteDataSource.swift**
```swift
import Foundation
import Supabase

final class ReceiptRemoteDataSource: ReceiptRepository, @unchecked Sendable {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func getReceipts() async throws -> [ReceiptEntity] {
        let dtos: [ReceiptDto] = try await client
            .from("receipts")
            .select()
            .execute()
            .value
        return dtos.map { $0.toEntity() }
    }

    func getReceipt(id: String) async throws -> ReceiptEntity {
        let dto: ReceiptDto = try await client
            .from("receipts")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
        return dto.toEntity()
    }

    func createReceipt(amount: Decimal) async throws -> ReceiptEntity {
        let dto: ReceiptDto = try await client
            .from("receipts")
            .insert(["amount": "\(amount)"])
            .select()
            .single()
            .execute()
            .value
        return dto.toEntity()
    }

    func deleteReceipt(id: String) async throws {
        try await client
            .from("receipts")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
```

## Step 3: Register in Factory

In `RepositoriesFactory.swift`:

```swift
public extension Container {
    var receiptRepository: Factory<ReceiptRepository> {
        self { ReceiptRemoteDataSource(client: self.supabaseClient()) }
    }
}
```

## Step 4: Use It

```swift
import Factory
import Repositories

class ReceiptViewModel: ObservableObject {
    @LazyInjected(\.receiptRepository) private var repository

    func load() async throws -> [ReceiptEntity] {
        try await repository.getReceipts()
    }
}
```

**Done!** No SwiftData setup needed.

---

# Case B: Local Only

Use for offline-first apps with no backend.

## Step 1: Create Core Layer (public)

Same as [Case A Step 1](#step-1-create-core-layer-public).

## Step 2: Create Local Layer (internal)

Create `Mods/Receipts/Local/` folder:

**ReceiptLocalModel.swift**
```swift
import Foundation
import SwiftData

@Model
final class ReceiptLocalModel {
    @Attribute(.unique) var id: String
    var amount: Decimal
    var date: Date

    init(id: String = UUID().uuidString, amount: Decimal, date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.date = date
    }

    func toEntity() -> ReceiptEntity {
        ReceiptEntity(id: id, amount: amount, date: date)
    }

    func update(from entity: ReceiptEntity) {
        self.amount = entity.amount
        self.date = entity.date
    }
}
```

**ReceiptLocalDataSource.swift**
```swift
import Foundation
import SwiftData

protocol ReceiptLocalDataSourceProtocol: Sendable {
    func getReceipts() async throws -> [ReceiptEntity]
    func getReceipt(id: String) async throws -> ReceiptEntity
    func saveReceipt(_ entity: ReceiptEntity) async throws
    func deleteReceipt(id: String) async throws
}

@ModelActor
actor ReceiptLocalDataSource: ReceiptLocalDataSourceProtocol {

    func getReceipts() async throws -> [ReceiptEntity] {
        let descriptor = FetchDescriptor<ReceiptLocalModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toEntity() }
    }

    func getReceipt(id: String) async throws -> ReceiptEntity {
        let descriptor = FetchDescriptor<ReceiptLocalModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw ReceiptError.notFound
        }
        return model.toEntity()
    }

    func saveReceipt(_ entity: ReceiptEntity) async throws {
        let descriptor = FetchDescriptor<ReceiptLocalModel>(
            predicate: #Predicate { $0.id == entity.id }
        )

        if let existing = try modelContext.fetch(descriptor).first {
            existing.update(from: entity)
        } else {
            let model = ReceiptLocalModel(
                id: entity.id,
                amount: entity.amount,
                date: entity.date
            )
            modelContext.insert(model)
        }
        try modelContext.save()
    }

    func deleteReceipt(id: String) async throws {
        let descriptor = FetchDescriptor<ReceiptLocalModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }
}
```

## Step 3: Add Model to Schema

In `RepositoriesFactory.swift`:

```swift
public enum RepositoriesSchema {
    public static var models: [any PersistentModel.Type] {
        [
            ProfileLocalModel.self,
            ReceiptLocalModel.self,  // Add here
        ]
    }
}
```

## Step 4: Create Local-Only Repository

Create a wrapper that implements the public protocol:

**ReceiptLocalRepository.swift** (in Local/ folder)
```swift
import Foundation
import SwiftData

final class ReceiptLocalRepository: ReceiptRepository, @unchecked Sendable {
    private let dataSource: ReceiptLocalDataSourceProtocol

    init(dataSource: ReceiptLocalDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func getReceipts() async throws -> [ReceiptEntity] {
        try await dataSource.getReceipts()
    }

    func getReceipt(id: String) async throws -> ReceiptEntity {
        try await dataSource.getReceipt(id: id)
    }

    func createReceipt(amount: Decimal) async throws -> ReceiptEntity {
        let entity = ReceiptEntity(
            id: UUID().uuidString,
            amount: amount,
            date: Date()
        )
        try await dataSource.saveReceipt(entity)
        return entity
    }

    func deleteReceipt(id: String) async throws {
        try await dataSource.deleteReceipt(id: id)
    }
}
```

## Step 5: Register in Factory

In `RepositoriesFactory.swift`:

```swift
// Internal: Local data source (nil until configured)
extension Container {
    var receiptLocalDataSource: Factory<ReceiptLocalDataSourceProtocol?> {
        self { nil }
    }
}

// Public: Repository uses local storage
public extension Container {
    var receiptRepository: Factory<ReceiptRepository> {
        self {
            guard let localDS = self.receiptLocalDataSource() else {
                fatalError("Call LocalStorageManager.configure() first")
            }
            return ReceiptLocalRepository(dataSource: localDS)
        }
    }
}
```

## Step 6: Update LocalStorageManager

In `LocalStorageManager.swift`, add:

```swift
// Property
private var receiptLocalDataSource: ReceiptLocalDataSourceProtocol?

// In configure() method, after container creation:
receiptLocalDataSource = ReceiptLocalDataSource(modelContainer: container)

Container.shared.receiptLocalDataSource.register { [weak self] in
    self?.receiptLocalDataSource
}
```

## Step 7: Configure in App

```swift
import SwiftUI
import Repositories
import Factory

@main
struct MyApp: App {
    init() {
        Container.shared.localStorageManager().configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(Container.shared.localStorageManager().container)
    }
}
```

## Step 8: Use It

Same as [Case A Step 4](#step-4-use-it).

---

# Case C: Local + Remote

Use when you need offline support with backend sync.

## Step 1: Create Core Layer (public)

Same as [Case A Step 1](#step-1-create-core-layer-public).

## Step 2: Create Remote Layer (internal)

Same as [Case A Step 2](#step-2-create-remote-layer-internal).

## Step 3: Create Local Layer (internal)

Same as [Case B Step 2](#step-2-create-local-layer-internal).

## Step 4: Add Model to Schema

Same as [Case B Step 3](#step-3-add-model-to-schema).

## Step 5: Create Service Layer (public)

Create `Mods/Receipts/Service/` folder:

**ReceiptService.swift**
```swift
import Foundation

public final class ReceiptService: ReceiptRepository, @unchecked Sendable {
    private let remoteDataSource: ReceiptRemoteDataSource
    private let localDataSource: ReceiptLocalDataSourceProtocol?

    init(
        remoteDataSource: ReceiptRemoteDataSource,
        localDataSource: ReceiptLocalDataSourceProtocol?
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    // MARK: - ReceiptRepository

    public func getReceipts() async throws -> [ReceiptEntity] {
        do {
            // Try remote first
            let entities = try await remoteDataSource.getReceipts()
            // Cache locally
            if let local = localDataSource {
                for entity in entities {
                    try? await local.saveReceipt(entity)
                }
            }
            return entities
        } catch {
            // Fallback to local cache
            if let local = localDataSource {
                return try await local.getReceipts()
            }
            throw error
        }
    }

    public func getReceipt(id: String) async throws -> ReceiptEntity {
        do {
            let entity = try await remoteDataSource.getReceipt(id: id)
            try? await localDataSource?.saveReceipt(entity)
            return entity
        } catch {
            if let local = localDataSource {
                return try await local.getReceipt(id: id)
            }
            throw error
        }
    }

    public func createReceipt(amount: Decimal) async throws -> ReceiptEntity {
        let entity = try await remoteDataSource.createReceipt(amount: amount)
        try? await localDataSource?.saveReceipt(entity)
        return entity
    }

    public func deleteReceipt(id: String) async throws {
        try await remoteDataSource.deleteReceipt(id: id)
        try? await localDataSource?.deleteReceipt(id: id)
    }

    // MARK: - Additional Methods

    /// Get cached data only (no network)
    public func getCached() async -> [ReceiptEntity] {
        guard let local = localDataSource else { return [] }
        return (try? await local.getReceipts()) ?? []
    }

    /// Force refresh from remote
    public func forceRefresh() async throws -> [ReceiptEntity] {
        let entities = try await remoteDataSource.getReceipts()
        if let local = localDataSource {
            for entity in entities {
                try? await local.saveReceipt(entity)
            }
        }
        return entities
    }
}
```

## Step 6: Register in Factory

In `RepositoriesFactory.swift`:

```swift
// Internal: Data sources
extension Container {
    var receiptRemoteDataSource: Factory<ReceiptRemoteDataSource> {
        self { ReceiptRemoteDataSource(client: self.supabaseClient()) }
    }

    var receiptLocalDataSource: Factory<ReceiptLocalDataSourceProtocol?> {
        self { nil }
    }
}

// Public: Service orchestrates both
public extension Container {
    var receiptRepository: Factory<ReceiptRepository> {
        self {
            ReceiptService(
                remoteDataSource: self.receiptRemoteDataSource(),
                localDataSource: self.receiptLocalDataSource()
            )
        }
    }
}
```

## Step 7: Update LocalStorageManager

Same as [Case B Step 6](#step-6-update-localstoragemanager).

## Step 8: Configure in App

Same as [Case B Step 7](#step-7-configure-in-app).

## Step 9: Use It

```swift
import Factory
import Repositories

class ReceiptViewModel: ObservableObject {
    @LazyInjected(\.receiptRepository) private var repository

    // Standard usage - remote first, fallback to cache
    func load() async throws -> [ReceiptEntity] {
        try await repository.getReceipts()
    }

    // Access service-specific methods
    func loadCached() async -> [ReceiptEntity] {
        guard let service = repository as? ReceiptService else { return [] }
        return await service.getCached()
    }

    func refresh() async throws -> [ReceiptEntity] {
        guard let service = repository as? ReceiptService else {
            return try await repository.getReceipts()
        }
        return try await service.forceRefresh()
    }
}
```

---

## Summary

| What | Remote Only | Local Only | Local + Remote |
|------|-------------|------------|----------------|
| Core/ | ✅ | ✅ | ✅ |
| Remote/ | ✅ | ❌ | ✅ |
| Local/ | ❌ | ✅ | ✅ |
| Service/ | ❌ | ❌ | ✅ |
| SwiftData setup | ❌ | ✅ | ✅ |
| Offline support | ❌ | ✅ | ✅ |

---

## Dependencies

- **Factory** - Dependency injection
- **SwiftData** - Local persistence (iOS 17+)
- **Supabase** - Backend client
