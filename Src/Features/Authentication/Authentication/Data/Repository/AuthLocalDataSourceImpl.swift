//
//  AuthLocalDataSourceImpl.swift
//  Authentication
//
//


// AuthLocalDataSourceImpl.swift
// Authentication module

import Foundation
import Security
import Common

class AuthLocalDataSourceImpl: AuthLocalDataSource {
    private let keychainService: KeychainServiceProtocol
    
    init(keychainService: KeychainServiceProtocol = KeychainService()) {
        self.keychainService = keychainService
    }
    
    func saveToken(_ token: AuthModel.AuthToken) async throws {
        // Create a codable wrapper to serialize the token
        let wrapper = TokenWrapper(token: token)
        let tokenData = try JSONEncoder().encode(wrapper)
        try keychainService.save(key: KeychainKeys.authToken, data: tokenData)
    }
    
    func getToken() async -> AuthModel.AuthToken? {
        do {
            let tokenData = try keychainService.retrieve(key: KeychainKeys.authToken)
            let wrapper = try JSONDecoder().decode(TokenWrapper.self, from: tokenData)
            return wrapper.token
        } catch {
            // Log error but return nil (no token found)
            return nil
        }
    }
    
    func clearToken() async throws {
        try keychainService.delete(key: KeychainKeys.authToken)
    }
}

// TokenWrapper to make AuthToken Codable
private struct TokenWrapper: Codable {
    let token: AuthModel.AuthToken
    
    // Coding keys that match the AuthToken properties
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case accessTokenExpiresAt
        case refreshTokenExpiresAt
        case user
        
        // User coding keys
        enum UserKeys: String, CodingKey {
            case id
            case email
            case isActive
        }
    }
    
    // Custom encoding for AuthToken
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(token.accessToken, forKey: .accessToken)
        try container.encode(token.refreshToken, forKey: .refreshToken)
        try container.encode(token.accessTokenExpiresAt, forKey: .accessTokenExpiresAt)
        try container.encode(token.refreshTokenExpiresAt, forKey: .refreshTokenExpiresAt)
        
        // Encode user
        var userContainer = container.nestedContainer(keyedBy: CodingKeys.UserKeys.self, forKey: .user)
        try userContainer.encode(token.user.id, forKey: .id)
        try userContainer.encode(token.user.email, forKey: .email)
        try userContainer.encode(token.user.isActive, forKey: .isActive)
    }
    
    // Custom decoding for AuthToken
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let accessToken = try container.decode(String.self, forKey: .accessToken)
        let refreshToken = try container.decode(String.self, forKey: .refreshToken)
        let accessTokenExpiresAt = try container.decode(Date.self, forKey: .accessTokenExpiresAt)
        let refreshTokenExpiresAt = try container.decode(Date.self, forKey: .refreshTokenExpiresAt)
        
        // Decode user
        let userContainer = try container.nestedContainer(keyedBy: CodingKeys.UserKeys.self, forKey: .user)
        let id = try userContainer.decode(String.self, forKey: .id)
        let email = try userContainer.decode(String.self, forKey: .email)
        let isActive = try userContainer.decode(Bool.self, forKey: .isActive)

        let user = AuthModel.User(id: id, email: email, isActive: isActive)
        self.token = AuthModel.AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            accessTokenExpiresAt: accessTokenExpiresAt,
            refreshTokenExpiresAt: refreshTokenExpiresAt,
            user: user
        )
    }
    
    // Constructor from AuthToken
    init(token: AuthModel.AuthToken) {
        self.token = token
    }
}

// Keychain constants
private enum KeychainKeys {
    static let authToken = "com.mosal.Authentication.authToken"
}
