//
//  SubscriptionError.swift
//  Subscriptions
//
//  Created by iOSJumpstart Developer on 3/13/25.
//

import Foundation

enum SubscriptionError: Error {
    case productNotFound
    case purchaseFailed(String)
    case networkError(String)
    case userCancelled
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .productNotFound:
            return "The selected product was not found."
        case .purchaseFailed(let reason):
            return "Purchase failed: \(reason)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .userCancelled:
            return "Purchase was cancelled"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
