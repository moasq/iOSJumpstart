//
//  MyProfileViewModel.swift
//  iOSJumpstart
//

import Foundation
import SwiftUI
import Factory
import Repositories
import FileHandler
import Authentication
import Common
import Events

@MainActor
class MyProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var profileState: Loadable<ProfileEntity?> = .notInitiated
    @Published var displayName: String = ""
    @Published var avatarURL: URL?
    @Published var selectedImageData: Data?
    @Published var error: Error?
    @Published private(set) var isSaving = false
    @Published private(set) var isRemovingAvatar = false

    // MARK: - Private Properties
    @LazyInjected(\.profileRepository) private var profileRepository
    @LazyInjected(\.fileServiceProvider) private var fileService
    @LazyInjected(\.authStatusRepository) private var authStatus
    @LazyInjected(\.eventViewModel) private var eventViewModel

    private var originalDisplayName: String = ""
    private var originalAvatarURL: URL?
    private var userId: String?

    // MARK: - Computed Properties
    var isLoading: Bool { profileState.isLoading }

    var hasChanges: Bool {
        displayName != originalDisplayName || selectedImageData != nil
    }

    var canSave: Bool {
        hasChanges && !isSaving
    }

    var hasAvatar: Bool {
        avatarURL != nil || selectedImageData != nil
    }

    // MARK: - Public Methods

    func loadProfile() async {
        profileState = .loading(existing: profileState.value)

        do {
            if let user = await authStatus.getCurrentUser() {
                userId = user.id
            }

            let profile = try await profileRepository.getProfile()
            displayName = profile.displayName ?? ""
            avatarURL = profile.avatarURL
            originalDisplayName = displayName
            originalAvatarURL = avatarURL
            profileState = .success(profile)

        } catch let profileError as ProfileError {
            if case .profileNotFound = profileError {
                displayName = ""
                originalDisplayName = ""
                profileState = .success(nil)
            } else {
                error = profileError
                profileState = .failure(profileError)
            }
        } catch {
            self.error = error
            profileState = .failure(error)
        }
    }

    func saveProfile() async -> Bool {
        guard hasChanges else { return true }

        isSaving = true
        error = nil

        do {
            var newAvatarURL: URL? = avatarURL

            if let imageData = selectedImageData {
                newAvatarURL = try await uploadProfileImage(imageData)
            }

            let request = UpdateProfileRequest(
                displayName: displayName.isEmpty ? nil : displayName,
                avatarURL: newAvatarURL
            )

            let updated = try await profileRepository.updateProfile(request: request)

            avatarURL = updated.avatarURL
            originalDisplayName = updated.displayName ?? ""
            originalAvatarURL = updated.avatarURL
            selectedImageData = nil
            isSaving = false

            // Emit profile updated event
            eventViewModel.emit(.profileUpdated)

            return true

        } catch {
            self.error = error
            isSaving = false
            return false
        }
    }

    func resetChanges() {
        displayName = originalDisplayName
        selectedImageData = nil
    }

    func removeAvatar() async {
        guard let userId = userId else { return }

        isRemovingAvatar = true
        error = nil

        do {
            // Delete avatar file from storage (ignore errors if file doesn't exist)
            let avatarPath = "avatars/\(userId).jpg"
            try? await fileService.delete(path: avatarPath, bucket: "storage")

            // Update profile to clear avatar URL
            let request = UpdateProfileRequest(
                displayName: displayName.isEmpty ? nil : displayName,
                clearAvatar: true
            )

            _ = try await profileRepository.updateProfile(request: request)

            // Update local state
            avatarURL = nil
            originalAvatarURL = nil
            selectedImageData = nil

            eventViewModel.emit(.profileUpdated)
        } catch {
            self.error = error
        }

        isRemovingAvatar = false
    }

    // MARK: - Private Methods

    /// Uploads profile image and returns the public URL
    private func uploadProfileImage(_ imageData: Data) async throws -> URL? {
        guard let userId = userId else { return nil }
        let fileName = "\(userId).jpg"
        let result = try await fileService.upload(
            data: imageData,
            fileName: fileName,
            options: .avatars(),
            compressionConfig: .default
        )
        return result.publicURL
    }
}
