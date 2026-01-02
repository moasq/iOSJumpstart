//
//  ProfileError.swift
//  Repositories
//

import Foundation

public enum ProfileError: Error, LocalizedError {
    case notAuthenticated
    case profileNotFound
    case profileAlreadyExists
    case invalidData(String)
    case networkError(Error)
    case serverError(String)
    case deletionFailed(Error)
    case localStorageError(Error)
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated"
        case .profileNotFound:
            return "User profile not found"
        case .profileAlreadyExists:
            return "Profile already exists for this user"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .deletionFailed(let error):
            return "Profile deletion failed: \(error.localizedDescription)"
        case .localStorageError(let error):
            return "Local storage error: \(error.localizedDescription)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}
