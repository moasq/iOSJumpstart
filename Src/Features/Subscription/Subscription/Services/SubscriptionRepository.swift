//
//  SubscriptionRepository.swift
//  Subscriptions
//
//  Created by iOSJumpstart Developer on 3/13/25.
//

import Foundation
import RevenueCat

// MARK: - Repository Protocol
protocol SubscriptionRepository {
    func getOfferings() async throws -> [SubscriptionModel.Offering]
    func purchase(productId: String) async throws -> SubscriptionModel.CustomerInfo
    func restorePurchases() async throws -> SubscriptionModel.CustomerInfo
    func getCurrentCustomerInfo() async throws -> SubscriptionModel.CustomerInfo
    func checkTrialEligibility(productIds: [String]) async throws -> [String: Bool]
}

// Cache actor for thread safety in async contexts
actor OfferingsCache {
    private var offerings: [SubscriptionModel.Offering]?
    private var isFetching = false
    
    func getOfferings() -> [SubscriptionModel.Offering]? {
        return offerings
    }
    
    func setOfferings(_ newOfferings: [SubscriptionModel.Offering]) {
        offerings = newOfferings
    }
    
    func setFetching(_ fetching: Bool) {
        isFetching = fetching
    }
    
    func isFetchingOfferings() -> Bool {
        return isFetching
    }
}

// MARK: - Repository Implementation
class SubscriptionRepositoryImpl: SubscriptionRepository {
    // MARK: - Properties
    private let service: RevenueCatService
    private let cache = OfferingsCache()
    
    // MARK: - Initialization
    init(service: RevenueCatService) {
        self.service = service
    }
    
    // MARK: - Repository Methods
    func getOfferings() async throws -> [SubscriptionModel.Offering] {
        // Check if offerings are already cached
        if let cachedOfferings = await cache.getOfferings() {
            return cachedOfferings
        }
        
        // If a fetch is already in progress, wait for it
        if await cache.isFetchingOfferings() {
            // Wait and check again
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            if let cachedOfferings = await cache.getOfferings() {
                return cachedOfferings
            }
        }
        
        // Start fetching
        await cache.setFetching(true)
        
        do {
            let offerings = try await service.getOfferings()
            
            let mappedOfferings = offerings.all.values.compactMap { offering in
                let products = offering.availablePackages.compactMap { package -> SubscriptionModel.Product? in
                    let product = package.storeProduct
                    
                    let period: SubscriptionModel.Period
                    if product.subscriptionPeriod?.unit == .year {
                        period = .yearly
                    } else if product.subscriptionPeriod?.unit == .week {
                        period = .weekly
                    } else {
                        period = .monthly
                    }
                    
                    let hasTrial = product.introductoryDiscount != nil
                    let trialDuration = product.introductoryDiscount?.paymentMode == .freeTrial ? 3 : 0
                    
                    return SubscriptionModel.Product(
                        id: product.productIdentifier,
                        title: product.localizedTitle,
                        description: product.localizedDescription,
                        price: product.price,
                        priceString: product.localizedPriceString,
                        period: period,
                        hasTrial: hasTrial,
                        trialDuration: trialDuration
                    )
                }
                
                return SubscriptionModel.Offering(
                    id: offering.identifier,
                    products: products
                )
            }
            
            // Cache the results
            await cache.setOfferings(mappedOfferings)
            await cache.setFetching(false)
            
            return mappedOfferings
        } catch {
            await cache.setFetching(false)
            throw SubscriptionError.networkError("Failed to fetch offerings: \(error.localizedDescription)")
        }
    }
    
    func purchase(productId: String) async throws -> SubscriptionModel.CustomerInfo {
        do {
            let offerings = try await service.getOfferings()
            
            guard let package = offerings.all.values.flatMap({ $0.availablePackages }).first(where: {
                $0.storeProduct.productIdentifier == productId
            }) else {
                throw SubscriptionError.productNotFound
            }
            
            let customerInfo = try await service.purchase(package: package)
            
            // Check if purchase actually activated the entitlement
            let hasAnyActiveEntitlements = customerInfo.entitlements.active.count > 0
            
            if !hasAnyActiveEntitlements {
                throw SubscriptionError.userCancelled
            }
            
            return mapCustomerInfo(customerInfo)
        } catch let error as NSError {
            if error.domain == "SKErrorDomain" && error.code == 2 {
                throw SubscriptionError.userCancelled
            } else {
                throw SubscriptionError.purchaseFailed(error.localizedDescription)
            }
        } catch let error as SubscriptionError {
            throw error
        } catch {
            // Detailed error examination
            if let nsError = error as NSError? {
                if nsError.domain == "SKErrorDomain" && nsError.code == 2 {
                    throw SubscriptionError.userCancelled
                }
            }
            throw SubscriptionError.unknown(error)
        }
    }
    
    func restorePurchases() async throws -> SubscriptionModel.CustomerInfo {
        do {
            let customerInfo = try await service.restorePurchases()
            return mapCustomerInfo(customerInfo)
        } catch {
            throw SubscriptionError.purchaseFailed("Failed to restore purchases: \(error.localizedDescription)")
        }
    }
    
    func getCurrentCustomerInfo() async throws -> SubscriptionModel.CustomerInfo {
        do {
            let customerInfo = try await service.getCustomerInfo()
            return mapCustomerInfo(customerInfo)
        } catch {
            throw SubscriptionError.networkError("Failed to get customer info: \(error.localizedDescription)")
        }
    }
    
    func checkTrialEligibility(productIds: [String]) async throws -> [String: Bool] {
        do {
            let eligibility = try await service.checkTrialEligibility(productIds: productIds)
            
            return eligibility.mapValues { eligibility in
                return eligibility.status.isEligible
            }
        } catch {
            throw SubscriptionError.networkError("Failed to check trial eligibility: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    private func mapCustomerInfo(_ customerInfo: CustomerInfo) -> SubscriptionModel.CustomerInfo {
        let entitlements = customerInfo.entitlements.all.mapValues { entitlement in
            return SubscriptionModel.Entitlement(
                id: entitlement.identifier,
                isActive: entitlement.isActive,
                expirationDate: entitlement.expirationDate,
                productId: entitlement.productIdentifier
            )
        }
        
        let isActive = customerInfo.entitlements.active.count > 0
        
        return SubscriptionModel.CustomerInfo(
            isActive: isActive,
            expirationDate: customerInfo.latestExpirationDate,
            entitlements: entitlements
        )
    }
}
