//
//  SubscriptionFactory.swift
//  Subscription
//
//

import Foundation
import Factory
import Common

// MARK: - Container Extensions
extension Container {
    // RevenueCat Service
    var revenueCatService: Factory<RevenueCatService> {
        self { RevenueCatService(apiKey: AppConfiguration.RevenueCat.apiKey) }
    }
    
    // Repository
    var subscriptionRepository: Factory<SubscriptionRepository> {
        self { SubscriptionRepositoryImpl(service: self.revenueCatService()) }
    }
    
}

public extension Container {
    var subscriptionCoordinator: Factory<SubscriptionCoordinatable> {
        self { SubscriptionCoordinator() }
    }
    
    var subscriptionManager: Factory<SubscriptionManager> {
        self { SubscriptionManager() }
            .scope(.shared)
    }
}
