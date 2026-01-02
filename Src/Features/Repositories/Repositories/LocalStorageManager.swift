//
//  LocalStorageManager.swift
//  Repositories
//
//  Centralized manager for SwiftData local storage.
//  Provides a clean, single-point configuration for all local data sources.
//

import Foundation
import SwiftData
import Factory
import os.log

private let logger = Logger(subsystem: "com.app.Repositories", category: "LocalStorageManager")

// MARK: - Protocol

/// Protocol for local storage management
public protocol LocalStorageManaging: Sendable {
    /// The SwiftData ModelContainer for all repository models
    var container: ModelContainer! { get }

    /// Whether the manager has been configured
    var isConfigured: Bool { get }

    /// Configures the local storage with all repository models
    @MainActor
    func configure(inMemory: Bool) throws

    /// Clears all local data
    func clearAllData() async throws

    /// Resets the manager
    @MainActor
    func reset()
}

// MARK: - Implementation

/// Centralized manager for all SwiftData local storage operations.
/// Handles ModelContainer creation and provides access to all local data sources.
///
/// Usage in main app:
/// ```swift
/// import Repositories
/// import Factory
///
/// @main
/// struct MyApp: App {
///     @Injected(\.localStorageManager) private var localStorage
///
///     init() {
///         Container.shared.localStorageManager().configure()
///     }
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///         }
///         .modelContainer(Container.shared.localStorageManager().container)
///     }
/// }
/// ```
public final class LocalStorageManager: LocalStorageManaging, @unchecked Sendable {

    // MARK: - Properties

    /// The SwiftData ModelContainer for all repository models
    public internal(set) var container: ModelContainer!

    /// Whether the manager has been configured
    public internal(set) var isConfigured = false

    // MARK: - Local Data Sources

    /// Profile local data source - lazily created after configuration
    internal var profileLocalDataSource: ProfileLocalDataSource?

    // MARK: - Initialization

    public init() {}

    // MARK: - Configuration

    /// Configures the local storage with all repository models.
    /// Call this once in your app's init before using any repositories.
    ///
    /// - Parameter inMemory: If true, uses in-memory storage (useful for previews/testing)
    @MainActor
    public func configure(inMemory: Bool) throws {
        guard !isConfigured else {
            logger.warning("LocalStorageManager already configured, skipping")
            return
        }

        // Create schema from all repository models
        let schema = Schema(RepositoriesSchema.models)

        // Configure model container
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        // Create local data sources
        profileLocalDataSource = ProfileLocalDataSource(modelContainer: container)

        // Register dependencies with Factory
        registerFactoryDependencies()

        isConfigured = true
        logger.info("LocalStorageManager configured successfully")
    }

    // MARK: - Factory Registration

    private func registerFactoryDependencies() {
        // Register profile local data source
        Container.shared.profileLocalDataSource.register { [weak self] in
            self?.profileLocalDataSource
        }

        // Register profile repository to use service with local caching
        Container.shared.profileRepository.register {
            ProfileService(
                remoteDataSource: Container.shared.profileRemoteDataSource(),
                localDataSource: Container.shared.profileLocalDataSource()
            )
        }

        logger.debug("Factory dependencies registered")
    }

    // MARK: - Convenience Methods

    /// Clears all local data. Useful for logout or testing.
    public func clearAllData() async throws {
        guard isConfigured else {
            logger.warning("LocalStorageManager not configured")
            return
        }

        try await profileLocalDataSource?.clearAll()
        logger.info("All local data cleared")
    }

    /// Resets the manager (useful for testing)
    @MainActor
    public func reset() {
        container = nil
        profileLocalDataSource = nil
        isConfigured = false

        // Reset factory registrations to defaults
        Container.shared.profileLocalDataSource.reset()
        Container.shared.profileRepository.reset()

        logger.info("LocalStorageManager reset")
    }
}

// MARK: - Factory Registration

public extension Container {
    /// Local storage manager - singleton scope ensures single ModelContainer
    var localStorageManager: Factory<LocalStorageManager> {
        self { LocalStorageManager() }
            .singleton
    }
}
