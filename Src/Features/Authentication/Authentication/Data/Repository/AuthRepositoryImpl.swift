//
//  AuthRepositoryImpl.swift
//  Authentication
//
//


import Foundation
import Factory
import Common
import Events

class AuthRepositoryImpl: AuthRepository {
    // Inject data sources
    @Injected(\.authRemoteDataSource) private var remoteDataSource: AuthRemoteDataSource
    @Injected(\.authLocalDataSource) private var localDataSource: AuthLocalDataSource
    @Injected(\.appleAuthProvider) private var appleProvider: AppleAuthProvider
    @Injected(\.googleAuthProvider) private var googleProvider: GoogleAuthProvider
    @Injected(\.eventViewModel) private var eventViewModel: EventViewModel
    
    // MARK: - Social Sign-in
    
    public func signInWithApple() async throws -> AuthModel.AuthToken {
        do {
            // 1. Get Apple credentials
            let appleResult = try await appleProvider.authenticate()
            
            // 2. Exchange with backend for token
            let tokenDto = try await remoteDataSource.authenticateWithApple(
                token: appleResult.token,
                nonce: appleResult.nonce,
                userData: appleResult.userData
            )
            
            // 3. Create and save token
            let token = tokenDto.toCore
            try await localDataSource.saveToken(token)
            
            // 4. Emit signed in event
            eventViewModel.emit(.userLoggedIn)
            
            return token
        } catch let error as NSError {
            switch error.domain {
            case "com.apple.authenticationservices":
                throw AuthError.userCancelled
            default:
                throw AuthError.authProviderError(error)
            }
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    public func signInWithGoogle() async throws -> AuthModel.AuthToken {
        do {
            // 1. Get Google credentials
            let googleResult = try await googleProvider.authenticate()

            // 2. Exchange with backend for token
            let tokenDto = try await remoteDataSource.authenticateWithGoogle(
                token: googleResult.token,
                nonce: googleResult.nonce,
                userData: googleResult.userData
            )

            // 3. Create and save token
            let token = tokenDto.toCore
            try await localDataSource.saveToken(token)

            // 4. Emit signed in event
            eventViewModel.emit(.userLoggedIn)

            return token
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.unknown(error)
        }
    }

    public func signInAnonymously() async throws -> AuthModel.AuthToken {
        do {
            // 1. Sign in anonymously via Supabase
            let tokenDto = try await remoteDataSource.authenticateAnonymously()

            // 2. Create and save token
            let token = tokenDto.toCore
            try await localDataSource.saveToken(token)

            // 3. Emit signed in event
            eventViewModel.emit(.userLoggedIn)

            return token
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.unknown(error)
        }
    }

    // MARK: - Token Management
    
    public func getCurrentToken() async -> AuthModel.AuthToken? {
        let token = await localDataSource.getToken()
        
        // If token exists but is expired, try to refresh
        if let token = token, token.isExpired {
            do {
                return try await refreshToken()
            } catch {
                // If refresh fails, return nil
                return nil
            }
        }
        
        return token
    }
    
    public func refreshToken() async throws -> AuthModel.AuthToken {
        guard let currentToken = await localDataSource.getToken() else {
            throw AuthError.invalidCredentials
        }
        
        do {
            let tokenDto = try await remoteDataSource.refreshToken(token: currentToken.refreshToken)
            let newToken = tokenDto.toCore
            try await localDataSource.saveToken(newToken)
            return newToken
        } catch {
            throw AuthError.refreshFailed
        }
    }
    
    // MARK: - Session Management
    
    public func logout() async throws {
        // Get token if available
        let token = await localDataSource.getToken()

        if let token = token {
            // Try to notify the server, but continue with local logout even if server call fails
            do {
                try await remoteDataSource.logout(token: token.accessToken)
            } catch {
                // Log the error but continue
            }

            // Clear the local token
            try await localDataSource.clearToken()
        }

        // Always emit logout event to update UI state
        eventViewModel.emit(.userLoggedOut)
    }
    
    public func deleteAccount() async throws {
        guard let token = await localDataSource.getToken() else {
            throw AuthError.invalidCredentials
        }
        
        try await remoteDataSource.deleteAccount(token: token.accessToken)
        
        // Clear local token after account deletion
        try await localDataSource.clearToken()
        
        // Emit logout event
        eventViewModel.emit(.userLoggedOut)
    }
    
    // MARK: - Status Check
    
    public func isAuthenticated() async -> Bool {
        guard let token = await getCurrentToken() else {
            return false
        }
        
        return !token.isExpired
    }
    
    public func getCurrentUser() async -> AuthModel.User? {
        guard let token = await getCurrentToken() else {
            return nil
        }

        return token.user
    }

    public func isAnonymous() async -> Bool {
        guard let user = await getCurrentUser() else { return false }
        return user.isAnonymous
    }
}

