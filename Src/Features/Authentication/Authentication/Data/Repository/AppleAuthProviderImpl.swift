//
//  AppleAuthProviderImpl.swift
//  Authentication
//
//


// Authentication/Data/Providers/AppleAuthProviderImpl.swift

import Foundation
import AuthenticationServices
import UIKit
import Common
import os.log

private let logger = Logger(subsystem: "com.mosal.iOSJumpstartApp.Authentication", category: "AppleAuth")

class AppleAuthProviderImpl: NSObject, AppleAuthProvider {
    func authenticate() async throws -> AuthModel.AppleAuthResult {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedScopes = [.fullName, .email]
                
                // Generate nonce
                let currentNonce = AuthUtils.randomNonceString()
                request.nonce = AuthUtils.sha256(currentNonce)
                
                let controller = ASAuthorizationController(authorizationRequests: [request])
                let delegate = AppleAuthDelegate(continuation: continuation, currentNonce: currentNonce)
                controller.delegate = delegate
                controller.presentationContextProvider = delegate
                controller.performRequests()
                
                // Store delegate as associated object to prevent it from being deallocated
                objc_setAssociatedObject(controller, "AppleAuthDelegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
}

// MARK: - Delegate for Apple authentication
@MainActor
private class AppleAuthDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let continuation: CheckedContinuation<AuthModel.AppleAuthResult, Error>
    private let currentNonce: String
    
    init(continuation: CheckedContinuation<AuthModel.AppleAuthResult, Error>, currentNonce: String) {
        self.continuation = continuation
        self.currentNonce = currentNonce
        super.init()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            continuation.resume(throwing: AuthError.authProviderError(NSError(
                domain: "AppleAuthProvider",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid credential"]
            )))
            return
        }
        
        // Extract user data
        var userData: [String: Any] = [:]
        
        // Add user ID
        userData["userIdentifier"] = credential.user
        
        // Add email if provided
        if let email = credential.email {
            userData["email"] = email
        }
        
        // Add name if provided
        if let fullName = credential.fullName {
            if let givenName = fullName.givenName {
                userData["firstName"] = givenName
            }
            
            if let familyName = fullName.familyName {
                userData["lastName"] = familyName
            }
            
            // Combine for full name
            if let givenName = fullName.givenName, let familyName = fullName.familyName {
                userData["fullName"] = "\(givenName) \(familyName)"
            }
        }
        
        // Create result
        let result = AuthModel.AppleAuthResult(token: tokenString, nonce: currentNonce, userData: userData)
        continuation.resume(returning: result)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        logger.error("Apple Sign In failed: \(error.localizedDescription)")
        // Convert error to AuthError
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                continuation.resume(throwing: AuthError.userCancelled)
            default:
                continuation.resume(throwing: AuthError.authProviderError(error))
            }
        } else {
            continuation.resume(throwing: AuthError.authProviderError(error))
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Find the window to present on
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            // Fallback if we can't find the window
            return UIWindow()
        }
        return window
    }
}