//
//  RevenueCatService.swift
//  Subscriptions
//
//  Created by iOSJumpstart Developer on 3/13/25.
//

import Foundation
import RevenueCat

class RevenueCatService {
    // MARK: - Properties
    private let configuration: Configuration
    // Add static flag to track initialization
    private static var isConfigured = false
    
    // MARK: - Initialization
    init(apiKey: String) {
        self.configuration = Configuration
            .builder(withAPIKey: apiKey)
            .with(storeKitVersion: .storeKit2)
            .build()
        
        // Only configure once
        if !RevenueCatService.isConfigured {
            Purchases.configure(with: configuration)
            RevenueCatService.isConfigured = true
            
            // Configure debug logging for development
            #if DEBUG
            Purchases.logLevel = .debug
            #else
            Purchases.logLevel = .info
            #endif
            
        } else {
        }
    }
    
    // MARK: - Public Methods
    func getOfferings() async throws -> Offerings {
        return try await Purchases.shared.offerings()
    }
    
    func purchase(package: Package) async throws -> CustomerInfo {
        let result = try await Purchases.shared.purchase(package: package)
        return result.customerInfo
    }
    
    func restorePurchases() async throws -> CustomerInfo {
        return try await Purchases.shared.restorePurchases()
    }
    
    func getCustomerInfo() async throws -> CustomerInfo {
        return try await Purchases.shared.customerInfo()
    }
    
    func checkTrialEligibility(productIds: [String]) async throws -> [String: IntroEligibility] {
            return  await Purchases.shared.checkTrialOrIntroDiscountEligibility(productIdentifiers: productIds)
       
    }
}
