//
//  SubscriptionModel.swift
//  Subscriptions
//
//  Created by iOSJumpstart Developer on 3/13/25.
//

import Foundation

enum SubscriptionModel {
    struct Product {
        let id: String
        let title: String
        let description: String
        let price: Decimal
        let priceString: String
        let period: Period
        let hasTrial: Bool
        let trialDuration: Int
    }
    
    enum Period: Equatable {
        case weekly
        case monthly
        case yearly
        
        var durationInMonths: Int {
            switch self {
            case .weekly: return 0 // Less than a month
            case .monthly: return 1
            case .yearly: return 12
            }
        }
        
        var description: String {
            switch self {
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .yearly: return "Yearly"
            }
        }
    }
    
    struct Offering {
        let id: String
        let products: [Product]
    }
    
    struct CustomerInfo {
        let isActive: Bool
        let expirationDate: Date?
        let entitlements: [String: Entitlement]
    }
    
    struct Entitlement {
        let id: String
        let isActive: Bool
        let expirationDate: Date?
        let productId: String?
    }
}
