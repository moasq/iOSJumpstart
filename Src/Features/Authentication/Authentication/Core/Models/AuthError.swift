//
//  AuthError.swift
//  Authentication
//
//


// AuthError.swift
// Authentication module

import Foundation

public enum AuthError: Error {
    case networkError(Error)
    case invalidCredentials
    case tokenExpired
    case refreshFailed
    case userCancelled
    case authProviderError(Error)
    case serverError(String)
    case decodingError(Error)
    case unknown(Error)
    
    public var errorDescription: String {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidCredentials:
            return "Invalid credentials"
        case .tokenExpired:
            return "Session expired, please sign in again"
        case .refreshFailed:
            return "Failed to refresh session"
        case .userCancelled:
            return "Authentication cancelled by user"
        case .authProviderError(let error):
            return "Authentication provider error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError(let error):
            return "Failed to process response: \(error.localizedDescription)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}