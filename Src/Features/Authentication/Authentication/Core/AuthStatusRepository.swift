//
//  AuthStatusRepository.swift
//  Authentication
//
//


import Foundation

public protocol AuthStatusRepository {
    func isAuthenticated() async -> Bool
    func getCurrentUser() async -> AuthModel.User?
    func getCurrentToken() async -> AuthModel.AuthToken?
}

class AuthStatusRepositoryImpl: AuthStatusRepository {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func isAuthenticated() async -> Bool {
        return await authRepository.isAuthenticated()
    }

    func getCurrentUser() async -> AuthModel.User? {
        return await authRepository.getCurrentUser()
    }

    func getCurrentToken() async -> AuthModel.AuthToken? {
        return await authRepository.getCurrentToken()
    }

    func isAnonymous() async -> Bool {
        return await authRepository.isAnonymous()
    }
}
