//
//  AuthRemoteDataSourceImpl.swift
//  Authentication
//
//


// AuthRemoteDataSourceImpl.swift
// Authentication module

import Foundation
import Supabase
import Auth
import Functions
import os.log

private let logger = Logger(subsystem: "com.mosal.iOSJumpstartApp.Authentication", category: "AuthRemoteDataSource")

// Typealias to disambiguate from Supabase's Auth.AuthError
typealias SupabaseAuthError = Auth.AuthError

class AuthRemoteDataSourceImpl: AuthRemoteDataSource {
    private let supabase: SupabaseClient

    init(supabase: SupabaseClient = SupabaseClientService.shared.client) {
        self.supabase = supabase
    }

    func authenticateWithApple(token: String, nonce: String?, userData: [String: Any]?) async throws -> AuthDto.Response {
        logger.debug("Authenticating with Apple. Token: \(token.prefix(10))... sentNonce: \(nonce ?? "nil")")
        do {
            let session = try await supabase.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: token,
                    nonce: nonce
                )
            )
            logger.debug("Apple authentication successful. User: \(session.user.id)")
            return mapSessionToResponse(session)
        } catch let error as SupabaseAuthError {
            logger.error("Supabase Apple Auth Error: \(error.localizedDescription)")
            throw mapSupabaseAuthError(error)
        } catch {
            logger.error("Unknown Apple Auth Error: \(error.localizedDescription)")
            throw AuthError.unknown(error)
        }
    }

    func authenticateWithGoogle(token: String, nonce: String?, userData: [String: Any]?) async throws -> AuthDto.Response {
        logger.debug("Authenticating with Google. Token: \(token.prefix(10))... sentNonce: \(nonce ?? "nil")")
        do {
            // Google requires accessToken - get from userData
            let accessToken = userData?["accessToken"] as? String

            let session = try await supabase.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .google,
                    idToken: token,
                    accessToken: accessToken,
                    nonce: nonce
                )
            )
            logger.debug("Google authentication successful. User: \(session.user.id)")
            return mapSessionToResponse(session)
        } catch let error as SupabaseAuthError {
            logger.error("Supabase Google Auth Error: \(error.localizedDescription)")
            throw mapSupabaseAuthError(error)
        } catch {
            logger.error("Unknown Google Auth Error: \(error)")
            throw AuthError.unknown(error)
        }
    }

    func authenticateAnonymously() async throws -> AuthDto.Response {
        logger.debug("Authenticating anonymously")
        do {
            let session = try await supabase.auth.signInAnonymously()
            logger.debug("Anonymous authentication successful. User: \(session.user.id)")
            return mapSessionToResponse(session)
        } catch let error as SupabaseAuthError {
            logger.error("Supabase Anonymous Auth Error: \(error.localizedDescription)")
            throw mapSupabaseAuthError(error)
        } catch {
            logger.error("Unknown Anonymous Auth Error: \(error.localizedDescription)")
            throw AuthError.unknown(error)
        }
    }

    func refreshToken(token: String) async throws -> AuthDto.Response {
        do {
            let session = try await supabase.auth.refreshSession()
            return mapSessionToResponse(session)
        } catch let error as SupabaseAuthError {
            throw mapSupabaseAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }

    func logout(token: String) async throws {
        do {
            try await supabase.auth.signOut()
        } catch let error as SupabaseAuthError {
            throw mapSupabaseAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }

    func deleteAccount(token: String) async throws {
        logger.debug("Deleting account via Edge Function")
        do {
            // Call the delete-user Edge Function
            // The Edge Function validates the JWT and uses admin API to delete the user
            // The invoke method throws on failure, returns Void on success
            try await supabase.functions.invoke(
                "delete-user",
                options: FunctionInvokeOptions(
                    headers: ["Authorization": "Bearer \(token)"]
                )
            )

            logger.debug("Account deleted successfully")
        } catch let error as FunctionsError {
            logger.error("Edge function error: \(error.localizedDescription)")
            throw AuthError.serverError(error.localizedDescription)
        } catch let error as AuthError {
            throw error
        } catch {
            logger.error("Unknown error deleting account: \(error.localizedDescription)")
            throw AuthError.unknown(error)
        }
    }

    // MARK: - Private Helpers

    private func mapSessionToResponse(_ session: Session) -> AuthDto.Response {
        let user = AuthDto.UserDto(
            id: session.user.id.uuidString,
            email: session.user.email ?? "",
            isActive: session.user.emailConfirmedAt != nil,
            isAnonymous: session.user.isAnonymous
        )

        return AuthDto.Response(
            user: user,
            accessToken: session.accessToken,
            accessTokenExpiresAt: Date(timeIntervalSince1970: session.expiresAt),
            refreshToken: session.refreshToken,
            refreshTokenExpiresAt: Date(timeIntervalSince1970: session.expiresAt + 604800) // Add 7 days for refresh token
        )
    }

    private func mapSupabaseAuthError(_ error: SupabaseAuthError) -> AuthError {
        switch error {
        case .sessionMissing:
            return .tokenExpired
        default:
            return .unknown(error)
        }
    }
}
