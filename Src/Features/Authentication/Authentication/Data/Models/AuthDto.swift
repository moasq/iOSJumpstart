//
//  AuthDto.swift
//  Authentication
//
//


// AuthDTO.swift
// Authentication module

import Foundation

enum AuthDto {
    struct Response: Decodable {
        let user: UserDto
        let accessToken: String
        let accessTokenExpiresAt: Date
        let refreshToken: String
        let refreshTokenExpiresAt: Date

        private enum CodingKeys: String, CodingKey {
            case user
            case accessToken = "access_token"
            case accessTokenExpiresAt = "access_token_expires_at"
            case refreshToken = "refresh_token"
            case refreshTokenExpiresAt = "refresh_token_expires_at"
        }

        // Direct initializer for Supabase session mapping
        init(
            user: UserDto,
            accessToken: String,
            accessTokenExpiresAt: Date,
            refreshToken: String,
            refreshTokenExpiresAt: Date
        ) {
            self.user = user
            self.accessToken = accessToken
            self.accessTokenExpiresAt = accessTokenExpiresAt
            self.refreshToken = refreshToken
            self.refreshTokenExpiresAt = refreshTokenExpiresAt
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            user = try container.decode(UserDto.self, forKey: .user)
            accessToken = try container.decode(String.self, forKey: .accessToken)
            refreshToken = try container.decode(String.self, forKey: .refreshToken)

            // Custom date decoding
            let expiresAtString = try container.decode(String.self, forKey: .accessTokenExpiresAt)
            let refreshExpiresAtString = try container.decode(String.self, forKey: .refreshTokenExpiresAt)

            // Create ISO 8601 date formatter with fractional seconds
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            // Parse dates
            if let date = dateFormatter.date(from: expiresAtString) {
                accessTokenExpiresAt = date
            } else {
                throw DecodingError.dataCorruptedError(
                    forKey: .accessTokenExpiresAt,
                    in: container,
                    debugDescription: "Invalid date format"
                )
            }

            if let date = dateFormatter.date(from: refreshExpiresAtString) {
                refreshTokenExpiresAt = date
            } else {
                throw DecodingError.dataCorruptedError(
                    forKey: .refreshTokenExpiresAt,
                    in: container,
                    debugDescription: "Invalid date format"
                )
            }
        }

        var toCore: AuthModel.AuthToken {
            return AuthModel.AuthToken(
                accessToken: accessToken,
                refreshToken: refreshToken,
                accessTokenExpiresAt: accessTokenExpiresAt,
                refreshTokenExpiresAt: refreshTokenExpiresAt,
                user: user.toCore
            )
        }
    }
      
    
    struct UserDto: Decodable {
        let id: String
        let email: String
        let isActive: Bool?
        let isAnonymous: Bool?

        private enum CodingKeys: String, CodingKey {
            case id
            case email
            case isActive = "is_active"
            case isAnonymous = "is_anonymous"
        }

        // Direct initializer for Supabase user mapping
        init(id: String, email: String, isActive: Bool?, isAnonymous: Bool? = nil) {
            self.id = id
            self.email = email
            self.isActive = isActive
            self.isAnonymous = isAnonymous
        }

        var toCore: AuthModel.User {
            return AuthModel.User(
                id: id,
                email: email,
                isActive: isActive ?? false,
                isAnonymous: isAnonymous ?? false
            )
        }
    }
    
    struct SocialAuthRequest: Encodable {
        let provider: String
        let token: String
        let userData: [String: Any]?
        
        enum CodingKeys: String, CodingKey {
            case provider
            case token
            case userData = "user_data"
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(provider, forKey: .provider)
            try container.encode(token, forKey: .token)
            
            if let userData = userData {
                // Convert dictionary to Data and then to JSON string
                let jsonData = try JSONSerialization.data(withJSONObject: userData)
                let jsonString = String(data: jsonData, encoding: .utf8)
                try container.encode(jsonString, forKey: .userData)
            }
        }
    }
    
    struct RefreshTokenRequest: Encodable {
        let refreshToken: String
        
        enum CodingKeys: String, CodingKey {
            case refreshToken = "refresh_token"
        }
    }
    
    struct EmptyRequest: Encodable {}
}
