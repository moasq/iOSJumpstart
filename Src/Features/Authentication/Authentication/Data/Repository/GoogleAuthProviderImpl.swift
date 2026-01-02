//
//  GoogleAuthProviderImpl.swift
//  Authentication
//
//


// Authentication/Data/Providers/GoogleAuthProviderImpl.swift

import Foundation
import GoogleSignIn
import UIKit
import Common
import os.log

private let logger = Logger(subsystem: "com.mosal.iOSJumpstartApp.Authentication", category: "GoogleAuth")

class GoogleAuthProviderImpl: GoogleAuthProvider {
    private let clientID: String
    
    init(clientID: String = EnvironmentVars.GOOGLE_CLIENT_ID) {
        self.clientID = clientID
    }
    
    func authenticate() async throws -> AuthModel.GoogleAuthResult {
        return try await withCheckedThrowingContinuation { continuation in
            // Ensure we're on the main thread for UI operations
            DispatchQueue.main.async {
                // 1. Generate raw nonce
                let rawNonce = AuthUtils.randomNonceString()

                // 2. Hash nonce with SHA256 for Google (Google expects hashed nonce)
                let hashedNonce = AuthUtils.sha256(rawNonce)

                // Create configuration
                let config = GIDConfiguration(clientID: self.clientID)

                // Configure Google Sign In
                GIDSignIn.sharedInstance.configuration = config

                // Get the top view controller to present from
                guard let topViewController = self.getTopViewController() else {
                    continuation.resume(throwing: AuthError.authProviderError(NSError(
                        domain: "GoogleAuthProvider",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No view controller available"]
                    )))
                    return
                }

                // 3. Sign in with Google using SDK 9.0.0 nonce-enabled method
                // Pass HASHED nonce to Google - Google will include it in the ID token
                GIDSignIn.sharedInstance.signIn(
                    withPresenting: topViewController,
                    hint: nil,
                    additionalScopes: nil,
                    nonce: hashedNonce
                ) { signInResult, error in
                    if let error = error {
                        logger.error("Google Sign In failed: \(error.localizedDescription)")
                        let nsError = error as NSError
                        if nsError.domain == "com.google.GIDSignIn" && nsError.code == -5 {
                            continuation.resume(throwing: AuthError.userCancelled)
                        } else {
                            continuation.resume(throwing: AuthError.authProviderError(error))
                        }
                        return
                    }
                    
                    guard let signInResult = signInResult,
                          let idToken = signInResult.user.idToken?.tokenString else {
                        continuation.resume(throwing: AuthError.authProviderError(NSError(
                            domain: "GoogleAuthProvider",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to get user or token"]
                        )))
                        return
                    }
                    
                    // Extract user data
                    var userData: [String: Any] = [:]

                    // Access token required by Supabase for Google auth
                    userData["accessToken"] = signInResult.user.accessToken.tokenString

                    // Basic user info
                    userData["userIdentifier"] = signInResult.user.userID
                    
                    // Profile data if available
                    if let profile = signInResult.user.profile {
                        userData["email"] = profile.email
                        userData["fullName"] = profile.name
                        userData["firstName"] = profile.givenName
                        userData["lastName"] = profile.familyName
                        
                        // Profile image
                        if let imageURL = profile.imageURL(withDimension: 200) {
                            userData["profileImageUrl"] = imageURL.absoluteString
                        }
                    }
                    
                    // 4. Return RAW nonce - Supabase will hash it and compare with token
                    let result = AuthModel.GoogleAuthResult(token: idToken, nonce: rawNonce, userData: userData)
                    continuation.resume(returning: result)
                }
            }
        }
    }
    
    // Helper to find the top view controller
    private func getTopViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
}