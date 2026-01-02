//
//  AuthenticationViewModel.swift
//  Authentication
//
//


import Foundation
import SwiftUI
import Factory
import Common
import os.log
import Events

private let logger = Logger(subsystem: "com.mosal.iOSJumpstartApp.Authentication", category: "AuthViewModel")

@Observable
class AuthenticationViewModel {
    // MARK: - Dependencies
    @ObservationIgnored
    @Injected(\.authRepository) private var repository: AuthRepository

    @ObservationIgnored
    @Injected(\.eventViewModel) private var eventViewModel: EventViewModel

    // MARK: - State
    var authState: Loadable<AuthModel.AuthToken> = .notInitiated
    var onAuthSuccess: (() -> Void)?
    
    // Add auth method enum
    enum AuthMethod {
        case none
        case apple
        case google
        case anonymous
    }
    
    // Add property to track current auth method
    var authMethod: AuthMethod = .none
    
    // MARK: - Methods
    func signInWithApple(completion: @escaping (Bool) -> Void = { _ in }) {
        authMethod = .apple
        Task {
            await signIn(using: {
                try await repository.signInWithApple()
            }, completion: completion)
        }
    }
    
    func signInWithGoogle(completion: @escaping (Bool) -> Void = { _ in }) {
        authMethod = .google
        Task {
            await signIn(using: {
                try await repository.signInWithGoogle()
            }, completion: completion)
        }
    }

    func signInAnonymously(completion: @escaping (Bool) -> Void = { _ in }) {
        authMethod = .anonymous
        Task {
            await signIn(using: {
                try await repository.signInAnonymously()
            }, completion: completion)
        }
    }

    private func signIn(using authMethod: () async throws -> AuthModel.AuthToken, completion: @escaping (Bool) -> Void) async {
        // Reset state
        await MainActor.run {
            authState = .loading(existing: authState.value)
        }
        
        do {
            let token = try await authMethod()
            
            await MainActor.run {
                authState = .success(token)
                // Emit login event
                eventViewModel.emit(.userLoggedIn)
                self.authMethod = .none  // Reset auth method
                completion(true)
            }
        } catch let error as AuthError {
            logger.error("Authentication failed: \(error.errorDescription)")
            await MainActor.run {
                authState = .failure(error)
                self.authMethod = .none  // Reset auth method
                completion(false)
            }
        } catch {
            logger.error("Unknown authentication error: \(error.localizedDescription)")
            await MainActor.run {
                authState = .failure(AuthError.unknown(error))
                self.authMethod = .none  // Reset auth method
                completion(false)
            }
        }
    }
    
    func logout(completion: @escaping () -> Void = {}) {
        Task {
            do {
                try await repository.logout()
                
                await MainActor.run {
                    authState = .notInitiated
                    // Emit logout event
                    eventViewModel.emit(.userLoggedOut)
                    completion()
                }
            } catch {
                // Even if there's an error with the remote logout, we still want to consider the user logged out locally
                await MainActor.run {
                    authState = .notInitiated
                    eventViewModel.emit(.userLoggedOut)
                    completion()
                }
            }
        }
    }
    
    // Add to AuthenticationViewModel.swift
    func deleteAccount() async throws {
        do {
            try await repository.deleteAccount()
            
            await MainActor.run {
                authState = .notInitiated
                // Emit user deleted event
                eventViewModel.emit(.userLoggedOut)
            }
        } catch let error as AuthError {
            await MainActor.run {
                authState = .failure(error)
            }
            throw error
        } catch {
            let wrappedError = AuthError.unknown(error)
            await MainActor.run {
                authState = .failure(wrappedError)
            }
            throw wrappedError
        }
    }
    
    
    // MARK: - Error handling
    func errorMessage(for error: AuthError) -> String {
        return error.errorDescription
    }
    
    // MARK: - Helper properties
    var isLoading: Bool {
        authState.isLoading
    }
    
    var error: AuthError? {
        authState.error as? AuthError
    }
    
    var isAuthenticated: Bool {
        if case .success = authState {
            return true
        }
        return false
    }
}
