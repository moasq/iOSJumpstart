//
//  ProfileEntity.swift
//  Repositories
//

import Foundation

public struct ProfileEntity: Sendable, Equatable {
    public let id: String
    public let email: String?
    public let avatarURL: URL?
    public let displayName: String?
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        email: String?,
        avatarURL: URL?,
        displayName: String?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.email = email
        self.avatarURL = avatarURL
        self.displayName = displayName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct CreateProfileRequest: Sendable {
    public let displayName: String?
    public let avatarURL: URL?

    public init(displayName: String? = nil, avatarURL: URL? = nil) {
        self.displayName = displayName
        self.avatarURL = avatarURL
    }
}

public struct UpdateProfileRequest: Sendable {
    public let displayName: String?
    public let avatarURL: URL?
    public let clearAvatar: Bool

    public init(displayName: String? = nil, avatarURL: URL? = nil, clearAvatar: Bool = false) {
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.clearAvatar = clearAvatar
    }
}
