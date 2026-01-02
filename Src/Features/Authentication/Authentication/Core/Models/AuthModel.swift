//
//  AuthModel.swift
//  Authentication
//
//


// AuthModels.swift
// Authentication module

import Foundation

public enum AuthModel {}

public extension AuthModel {
    struct AuthToken {
        public let accessToken: String
        let refreshToken: String
        let accessTokenExpiresAt: Date
        let refreshTokenExpiresAt: Date
        let user: User
        
        var isExpired: Bool {
            return Date() >= accessTokenExpiresAt
        }
    }
    
    struct User {
        public let id: String
        public let email: String
        public let isActive: Bool
        public let isAnonymous: Bool

        public init(id: String, email: String, isActive: Bool, isAnonymous: Bool = false) {
            self.id = id
            self.email = email
            self.isActive = isActive
            self.isAnonymous = isAnonymous
        }
    }
    
    struct AppleAuthResult {
        let token: String
        let nonce: String?
        let userData: [String: Any]?
    }

    
    struct GoogleAuthResult {
        let token: String
        let nonce: String?
        let userData: [String: Any]?
    }
}
