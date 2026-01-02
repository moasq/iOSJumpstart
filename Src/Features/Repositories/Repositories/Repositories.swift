//
//  Repositories.swift
//  Repositories
//
//  This module provides data access repositories for both local (SwiftData) and remote (Supabase) operations.
//
//  Usage:
//  ```swift
//  import Repositories
//  import Factory
//
//  @Injected(\.profileRepository) private var profileRepository
//
//  // Create profile
//  let profile = try await profileRepository.createProfile(
//      request: CreateProfileRequest(displayName: "John")
//  )
//
//  // Get profile
//  let profile = try await profileRepository.getProfile()
//
//  // Update profile
//  let updated = try await profileRepository.updateProfile(
//      request: UpdateProfileRequest(displayName: "Jane")
//  )
//
//  // Delete profile
//  try await profileRepository.deleteProfile()
//  ```
//

import Foundation

// MARK: - Public Type Aliases

public typealias Profile = ProfileEntity
