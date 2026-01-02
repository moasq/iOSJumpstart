//
//  SubscriptionCoordinator.swift
//  Subscriptions
//
//  Created by iOSJumpstart Developer on 3/13/25.
//

import UIKit
import SwiftUI
import Factory
import RevenueCatUI

public protocol SubscriptionCoordinatable: AnyObject {
    func presentPaywall(from navigationController: UINavigationController)
    func dismissPaywall()
    func paywallView() -> AnyView
    func restorePurchases() async
}

public class SubscriptionCoordinator: SubscriptionCoordinatable {
    @LazyInjected(\.subscriptionManager) private var subscriptionManager: SubscriptionManager
    @LazyInjected(\.subscriptionRepository) private var subscriptionRepository: SubscriptionRepository

    // MARK: - Initialization
    public init() {}

    // MARK: - Public Methods
    public func presentPaywall(from navigationController: UINavigationController) {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")

        let paywallView = PaywallView()
            .onPurchaseCompleted { [weak self] _ in
                navigationController.dismiss(animated: true)
                Task { @MainActor in
                    await self?.subscriptionManager.refreshSubscriptionStatus()
                }
            }
            .onRestoreCompleted { [weak self] _ in
                navigationController.dismiss(animated: true)
                Task { @MainActor in
                    await self?.subscriptionManager.refreshSubscriptionStatus()
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)

        let hostingController = UIHostingController(rootView: paywallView)
        hostingController.modalPresentationStyle = .formSheet
        hostingController.overrideUserInterfaceStyle = isDarkMode ? .dark : .light

        navigationController.present(hostingController, animated: true)
    }

    public func dismissPaywall() {
        // Dismissal handled by callbacks
    }

    public func paywallView() -> AnyView {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")

        let view = PaywallView()
            .onPurchaseCompleted { [weak self] _ in
                Task { @MainActor in
                    await self?.subscriptionManager.refreshSubscriptionStatus()
                }
            }
            .onRestoreCompleted { [weak self] _ in
                Task { @MainActor in
                    await self?.subscriptionManager.refreshSubscriptionStatus()
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)

        return AnyView(view)
    }

    public func restorePurchases() async {
        do {
            _ = try await subscriptionRepository.restorePurchases()
            await subscriptionManager.refreshSubscriptionStatus()
        } catch {
            // Silently fail - the paywall will handle any errors
        }
    }
}
