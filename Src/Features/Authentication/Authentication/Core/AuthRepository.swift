//
//  AuthRepository.swift
//  Authentication
//
//


// AuthRepository.swift
// Authentication module

import Foundation

public protocol AuthRepository {
    // Social sign-in
    func signInWithApple() async throws -> AuthModel.AuthToken
    func signInWithGoogle() async throws -> AuthModel.AuthToken
    func signInAnonymously() async throws -> AuthModel.AuthToken

    // Token management
    func getCurrentToken() async -> AuthModel.AuthToken?
    func refreshToken() async throws -> AuthModel.AuthToken

    // Session management
    func logout() async throws
    func deleteAccount() async throws

    // Status check
    func isAuthenticated() async -> Bool
    func getCurrentUser() async -> AuthModel.User?
    func isAnonymous() async -> Bool
}
