//
//  RepositoriesFactory.swift
//  Repositories
//
//  Factory registrations for the Repositories module.
//

import Foundation
import Factory
import SwiftData

// MARK: - Internal Dependencies

extension Container {
    /// Remote data source for profiles (Supabase)
    var profileRemoteDataSource: Factory<ProfileRemoteDataSource> {
        self { ProfileRemoteDataSource() }
    }
}

// MARK: - Public Dependencies

public extension Container {

    /// Profile repository - uses remote only by default.
    /// When LocalStorageManager is configured, this automatically uses ProfileService with local caching.
    var profileRepository: Factory<ProfileRepository> {
        self { self.profileRemoteDataSource() }
    }


    /// Local data source for profiles (SwiftData).
    /// Automatically registered by LocalStorageManager.configure()
    var profileLocalDataSource: Factory<ProfileLocalDataSourceProtocol?> {
        self { nil }
    }
}

// MARK: - Model Configuration

/// Schema for all SwiftData models in the Repositories module.
public enum RepositoriesSchema {
    /// All SwiftData model types in the Repositories module.
    /// Add new models here as they are created.
    public static var models: [any PersistentModel.Type] {
        [
            ProfileLocalModel.self,
            // Add more models here:
            // ReceiptLocalModel.self,
            // SettingsLocalModel.self,
        ]
    }
}
