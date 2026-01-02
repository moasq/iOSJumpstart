//
//  ProfileDto.swift
//  Repositories
//

import Foundation

enum ProfileDto {
    struct Response: Decodable, Sendable {
        let id: String
        let email: String?
        let avatarUrl: String?
        let displayName: String?
        let createdAt: String
        let updatedAt: String

        private enum CodingKeys: String, CodingKey {
            case id
            case email
            case avatarUrl = "avatar_url"
            case displayName = "display_name"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }

        var toEntity: ProfileEntity {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            return ProfileEntity(
                id: id,
                email: email,
                avatarURL: avatarUrl.flatMap { URL(string: $0) },
                displayName: displayName,
                createdAt: dateFormatter.date(from: createdAt) ?? Date(),
                updatedAt: dateFormatter.date(from: updatedAt) ?? Date()
            )
        }
    }

    struct CreateRequest: Encodable, Sendable {
        let displayName: String?
        let avatarUrl: String?

        private enum CodingKeys: String, CodingKey {
            case displayName = "display_name"
            case avatarUrl = "avatar_url"
        }

        init(from request: CreateProfileRequest) {
            self.displayName = request.displayName
            self.avatarUrl = request.avatarURL?.absoluteString
        }
    }

    struct UpdateRequest: Encodable, Sendable {
        let displayName: String?
        let avatarUrl: String?
        private let clearAvatar: Bool

        private enum CodingKeys: String, CodingKey {
            case displayName = "display_name"
            case avatarUrl = "avatar_url"
        }

        init(from request: UpdateProfileRequest) {
            self.displayName = request.displayName
            self.avatarUrl = request.avatarURL?.absoluteString
            self.clearAvatar = request.clearAvatar
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            // Always encode displayName if present
            if let displayName = displayName {
                try container.encode(displayName, forKey: .displayName)
            }

            // Explicitly encode null for avatarUrl when clearing
            if clearAvatar {
                try container.encodeNil(forKey: .avatarUrl)
            } else if let avatarUrl = avatarUrl {
                try container.encode(avatarUrl, forKey: .avatarUrl)
            }
        }
    }
}
