//
//  ProfileService.swift
//  Repositories
//
//  Service layer that orchestrates between local (SwiftData) and remote (Supabase) data sources.
//  Implements caching strategy: remote-first with local fallback.
//

import Foundation
import Factory
import Authentication
import os.log

private let logger = Logger(subsystem: "com.app.Repositories", category: "ProfileService")

/// Service that coordinates between local and remote data sources
final class ProfileService: ProfileRepository, @unchecked Sendable {
    @Injected(\.authStatusRepository) private var authStatus: AuthStatusRepository

    private let remoteDataSource: ProfileRemoteDataSource
    private let localDataSource: ProfileLocalDataSourceProtocol?

    /// Creates a ProfileService with optional local caching
    /// - Parameters:
    ///   - remoteDataSource: The remote data source (Supabase)
    ///   - localDataSource: Optional local data source (SwiftData). If nil, no caching is performed.
    init(
        remoteDataSource: ProfileRemoteDataSource = ProfileRemoteDataSource(),
        localDataSource: ProfileLocalDataSourceProtocol? = nil
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    // MARK: - Create Profile

    func createProfile(request: CreateProfileRequest) async throws -> ProfileEntity {
        logger.debug("Creating profile via service")

        // Create on remote first
        let profile = try await remoteDataSource.createProfile(request: request)

        // Cache locally if local data source is available
        if let local = localDataSource {
            do {
                try await local.saveProfile(profile)
                logger.debug("Profile cached locally after creation")
            } catch {
                // Log but don't fail - caching is optional
                logger.warning("Failed to cache profile locally: \(error.localizedDescription)")
            }
        }

        return profile
    }

    // MARK: - Get Profile

    func getProfile() async throws -> ProfileEntity {
        logger.debug("Fetching profile via service")

        // Try remote first
        do {
            let profile = try await remoteDataSource.getProfile()

            // Cache locally
            if let local = localDataSource {
                do {
                    try await local.saveProfile(profile)
                    logger.debug("Profile cached locally after fetch")
                } catch {
                    logger.warning("Failed to cache profile locally: \(error.localizedDescription)")
                }
            }

            return profile

        } catch {
            // If remote fails and we have a local data source, try local cache
            if let local = localDataSource {
                logger.debug("Remote fetch failed, trying local cache")

                // Get current user ID to fetch from local
                if let user = await authStatus.getCurrentUser(),
                   let cachedProfile = try await local.getProfile(for: user.id) {
                    logger.debug("Returning cached profile")
                    return cachedProfile
                }
            }

            // Re-throw the original error if no cached data
            throw error
        }
    }

    // MARK: - Update Profile

    func updateProfile(request: UpdateProfileRequest) async throws -> ProfileEntity {
        logger.debug("Updating profile via service")

        // Update on remote first
        let profile = try await remoteDataSource.updateProfile(request: request)

        // Update local cache
        if let local = localDataSource {
            do {
                try await local.saveProfile(profile)
                logger.debug("Local cache updated after profile update")
            } catch {
                logger.warning("Failed to update local cache: \(error.localizedDescription)")
            }
        }

        return profile
    }

    // MARK: - Additional Service Methods

    /// Clears all cached data
    func clearLocalCache() async throws {
        guard let local = localDataSource else { return }
        try await local.clearAll()
        logger.debug("Local cache cleared")
    }

    /// Forces a refresh from remote and updates local cache
    func forceRefresh() async throws -> ProfileEntity {
        logger.debug("Force refreshing profile from remote")

        let profile = try await remoteDataSource.getProfile()

        if let local = localDataSource {
            try await local.saveProfile(profile)
        }

        return profile
    }

    /// Returns cached profile without hitting remote (if available)
    func getCachedProfile() async -> ProfileEntity? {
        guard let local = localDataSource,
              let user = await authStatus.getCurrentUser() else {
            return nil
        }

        return try? await local.getProfile(for: user.id)
    }
}
