//
//  SubscriptionManager.swift
//  Subscription
//
//

import Foundation
import Observation
import Factory
import Common
import Events

@Observable
public final class SubscriptionManager {
    @ObservationIgnored
    @LazyInjected(\.subscriptionRepository) private var repository
    
    @ObservationIgnored
    @LazyInjected(\.eventViewModel) private var eventViewModel
    
    private let entitlementId = AppConfiguration.RevenueCat.entitlementID
    public private(set) var isSubscribed = false
    public private(set) var lastRefreshTime: Date?
    
    
    init() {
        Task { await refreshSubscriptionStatus() }
        
        // Subscribe to authentication events
        eventViewModel.subscribe(for: self, to: [.authentication]) { [weak self] event in
            if event == .userLoggedIn {
                Task { [weak self] in
                    await self?.refreshSubscriptionStatus()
                }
            }
        }
    }
    
    @MainActor
    func refreshSubscriptionStatus() async {
        
        do {
            let customerInfo = try await repository.getCurrentCustomerInfo()
            let wasSubscribed = isSubscribed
            let newStatus = customerInfo.entitlements[entitlementId]?.isActive ?? false
            
            isSubscribed = newStatus
            lastRefreshTime = Date()
            
            
            // Emit event only when subscription becomes active
            if !wasSubscribed && isSubscribed {
                eventViewModel.emit(.userSubscribed)
            }
        } catch {
        }
    }
}
