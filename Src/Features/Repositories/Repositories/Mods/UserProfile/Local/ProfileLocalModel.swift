//
//  ProfileLocalModel.swift
//  Repositories
//
//  SwiftData model for local profile storage.
//  Note: SwiftData ModelContainer should be configured in the main app.
//

import Foundation
import SwiftData

/// SwiftData model for storing user profile locally
@Model
public final class ProfileLocalModel {
    @Attribute(.unique) public var id: String
    public var email: String?
    public var avatarURLString: String?
    public var displayName: String?
    public var createdAt: Date
    public var updatedAt: Date

    /// Tracks if the local data needs to be synced with remote
    public var needsSync: Bool

    /// Last time the profile was fetched from remote
    public var lastFetchedAt: Date?

    public init(
        id: String,
        email: String? = nil,
        avatarURLString: String? = nil,
        displayName: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        needsSync: Bool = false,
        lastFetchedAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.avatarURLString = avatarURLString
        self.displayName = displayName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.needsSync = needsSync
        self.lastFetchedAt = lastFetchedAt
    }

    /// Convenience initializer from ProfileEntity
    public convenience init(from entity: ProfileEntity) {
        self.init(
            id: entity.id,
            email: entity.email,
            avatarURLString: entity.avatarURL?.absoluteString,
            displayName: entity.displayName,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            needsSync: false,
            lastFetchedAt: Date()
        )
    }

    /// Converts to ProfileEntity
    public var toEntity: ProfileEntity {
        ProfileEntity(
            id: id,
            email: email,
            avatarURL: avatarURLString.flatMap { URL(string: $0) },
            displayName: displayName,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    /// Updates the model from a ProfileEntity
    public func update(from entity: ProfileEntity) {
        self.email = entity.email
        self.avatarURLString = entity.avatarURL?.absoluteString
        self.displayName = entity.displayName
        self.updatedAt = entity.updatedAt
        self.lastFetchedAt = Date()
        self.needsSync = false
    }
}
