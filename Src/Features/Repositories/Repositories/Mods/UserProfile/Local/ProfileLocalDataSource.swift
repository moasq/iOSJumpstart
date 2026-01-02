//
//  ProfileLocalDataSource.swift
//  Repositories
//
//  Local data source for profile using SwiftData.
//  Provides caching and offline support for profile data.
//

import Foundation
import SwiftData
import os.log

private let logger = Logger(subsystem: "com.app.Repositories", category: "ProfileLocalDataSource")

/// Protocol for local profile storage operations
public protocol ProfileLocalDataSourceProtocol: Sendable {
    /// Saves a profile to local storage
    func saveProfile(_ entity: ProfileEntity) async throws

    /// Fetches the cached profile for a user ID
    func getProfile(for userId: String) async throws -> ProfileEntity?

    /// Deletes the cached profile
    func deleteProfile(for userId: String) async throws

    /// Clears all cached profiles
    func clearAll() async throws

    /// Checks if we have a cached profile
    func hasCachedProfile(for userId: String) async -> Bool
}

/// SwiftData-based local data source for profiles
@ModelActor
public actor ProfileLocalDataSource: ProfileLocalDataSourceProtocol {

    // MARK: - Save Profile

    public func saveProfile(_ entity: ProfileEntity) async throws {
        logger.debug("Saving profile to local storage: \(entity.id)")

        do {
            // Check if profile already exists
            let entityId = entity.id
            let descriptor = FetchDescriptor<ProfileLocalModel>(
                predicate: #Predicate { $0.id == entityId }
            )

            if let existingProfile = try modelContext.fetch(descriptor).first {
                // Update existing profile
                existingProfile.update(from: entity)
                logger.debug("Updated existing profile in local storage")
            } else {
                // Create new profile
                let localModel = ProfileLocalModel(from: entity)
                modelContext.insert(localModel)
                logger.debug("Inserted new profile to local storage")
            }

            try modelContext.save()

        } catch {
            logger.error("Failed to save profile to local storage: \(error.localizedDescription)")
            throw ProfileError.localStorageError(error)
        }
    }

    // MARK: - Get Profile

    public func getProfile(for userId: String) async throws -> ProfileEntity? {
        logger.debug("Fetching profile from local storage: \(userId)")

        do {
            let descriptor = FetchDescriptor<ProfileLocalModel>(
                predicate: #Predicate { $0.id == userId }
            )

            let profiles = try modelContext.fetch(descriptor)

            if let profile = profiles.first {
                logger.debug("Found profile in local storage")
                return profile.toEntity
            }

            logger.debug("No profile found in local storage")
            return nil

        } catch {
            logger.error("Failed to fetch profile from local storage: \(error.localizedDescription)")
            throw ProfileError.localStorageError(error)
        }
    }

    // MARK: - Delete Profile

    public func deleteProfile(for userId: String) async throws {
        logger.debug("Deleting profile from local storage: \(userId)")

        do {
            let descriptor = FetchDescriptor<ProfileLocalModel>(
                predicate: #Predicate { $0.id == userId }
            )

            let profiles = try modelContext.fetch(descriptor)

            for profile in profiles {
                modelContext.delete(profile)
            }

            try modelContext.save()
            logger.debug("Profile deleted from local storage")

        } catch {
            logger.error("Failed to delete profile from local storage: \(error.localizedDescription)")
            throw ProfileError.localStorageError(error)
        }
    }

    // MARK: - Clear All

    public func clearAll() async throws {
        logger.debug("Clearing all profiles from local storage")

        do {
            try modelContext.delete(model: ProfileLocalModel.self)
            try modelContext.save()
            logger.debug("All profiles cleared from local storage")

        } catch {
            logger.error("Failed to clear profiles from local storage: \(error.localizedDescription)")
            throw ProfileError.localStorageError(error)
        }
    }

    // MARK: - Has Cached Profile

    public func hasCachedProfile(for userId: String) async -> Bool {
        do {
            let descriptor = FetchDescriptor<ProfileLocalModel>(
                predicate: #Predicate { $0.id == userId }
            )
            let count = try modelContext.fetchCount(descriptor)
            return count > 0
        } catch {
            logger.error("Failed to check cached profile: \(error.localizedDescription)")
            return false
        }
    }
}
