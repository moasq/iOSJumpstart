//
//  ProfileRepository.swift
//  Repositories
//

import Foundation

public protocol ProfileRepository: Sendable {
    /// Creates a new user profile
    func createProfile(request: CreateProfileRequest) async throws -> ProfileEntity

    /// Fetches the current user's profile
    func getProfile() async throws -> ProfileEntity

    /// Updates the current user's profile
    func updateProfile(request: UpdateProfileRequest) async throws -> ProfileEntity
}
