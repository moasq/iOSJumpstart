//
//  ProfileRemoteDataSource.swift
//  Repositories
//

import Foundation
import Factory
import PostgREST
import Authentication
import os.log

private let logger = Logger(subsystem: "com.app.Repositories", category: "ProfileRemoteDataSource")

final class ProfileRemoteDataSource: ProfileRepository, @unchecked Sendable {
    @Injected(\.authStatusRepository) private var authStatus: AuthStatusRepository

    private let profileClient: SupabaseProfileClient
    private let tableName = "profiles"

    init(profileClient: SupabaseProfileClient = .shared) {
        self.profileClient = profileClient
    }

    // MARK: - Create Profile

    func createProfile(request: CreateProfileRequest) async throws -> ProfileEntity {
        guard await authStatus.isAuthenticated() else {
            throw ProfileError.notAuthenticated
        }

        logger.debug("Creating profile")

        do {
            let createRequest = ProfileDto.CreateRequest(from: request)

            let response: ProfileDto.Response = try await profileClient.database
                .from(tableName)
                .insert(createRequest)
                .select()
                .single()
                .execute()
                .value

            logger.debug("Profile created successfully")
            return response.toEntity

        } catch let error as NSError {
            logger.error("Error creating profile: \(error.localizedDescription)")
            if error.localizedDescription.contains("duplicate") {
                throw ProfileError.profileAlreadyExists
            }
            throw ProfileError.serverError(error.localizedDescription)
        } catch {
            logger.error("Unknown error creating profile: \(error)")
            throw ProfileError.unknown(error)
        }
    }

    // MARK: - Get Profile

    func getProfile() async throws -> ProfileEntity {
        guard await authStatus.isAuthenticated() else {
            throw ProfileError.notAuthenticated
        }

        logger.debug("Fetching user profile")

        do {
            let response: ProfileDto.Response = try await profileClient.database
                .from(tableName)
                .select()
                .single()
                .execute()
                .value

            logger.debug("Profile fetched successfully")
            return response.toEntity

        } catch is CancellationError {
            logger.debug("Profile fetch cancelled")
            throw CancellationError()
        } catch let error as NSError {
            // Check for cancellation
            if error.code == NSURLErrorCancelled || error.localizedDescription.contains("cancelled") {
                logger.debug("Profile fetch cancelled")
                throw CancellationError()
            }
            logger.error("Error fetching profile: \(error.localizedDescription)")
            if error.localizedDescription.contains("not found") || error.localizedDescription.contains("0 rows") {
                throw ProfileError.profileNotFound
            }
            throw ProfileError.serverError(error.localizedDescription)
        } catch {
            logger.error("Unknown error fetching profile: \(error)")
            throw ProfileError.unknown(error)
        }
    }

    // MARK: - Update Profile

    func updateProfile(request: UpdateProfileRequest) async throws -> ProfileEntity {
        guard let userId = await authStatus.getCurrentUser()?.id else {
            throw ProfileError.notAuthenticated
        }

        logger.debug("Updating user profile for user: \(userId)")

        do {
            let updateRequest = ProfileDto.UpdateRequest(from: request)

            let response: ProfileDto.Response = try await profileClient.database
                .from(tableName)
                .update(updateRequest)
                .eq("id", value: userId)
                .select()
                .single()
                .execute()
                .value

            logger.debug("Profile updated successfully")
            return response.toEntity

        } catch let error as ProfileError {
            throw error
        } catch {
            logger.error("Unknown error updating profile: \(error)")
            throw ProfileError.unknown(error)
        }
    }

}
