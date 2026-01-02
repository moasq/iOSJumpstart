//
//  ShowcaseViewModel.swift
//  iOSJumpstart
//
//

import Foundation
import Factory
import Subscription
import UIKit

@MainActor
class ShowcaseViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var notificationStatus: NotificationPermission = .notDetermined
    @Published private(set) var isSubscribed: Bool = false
    @Published private(set) var isCheckingNotifications: Bool = false
    @Published private(set) var isRestoringPurchases: Bool = false

    // MARK: - Dependencies

    @LazyInjected(\.notificationService) private var notificationService: NotificationService
    @LazyInjected(\.subscriptionManager) private var subscriptionManager: SubscriptionManager
    @LazyInjected(\.subscriptionCoordinator) private var subscriptionCoordinator: SubscriptionCoordinatable

    // MARK: - Computed Properties

    var notificationButtonTitle: String {
        switch notificationStatus {
        case .notDetermined:
            return "Enable Notifications"
        case .authorized, .provisional:
            return "Notifications Enabled"
        case .denied:
            return "Open Settings"
        }
    }

    var notificationStatusText: String {
        switch notificationStatus {
        case .notDetermined:
            return "Not configured"
        case .authorized, .provisional:
            return "Enabled"
        case .denied:
            return "Disabled"
        }
    }

    var isNotificationEnabled: Bool {
        notificationStatus == .authorized || notificationStatus == .provisional
    }

    var subscriptionStatusText: String {
        isSubscribed ? "Pro Member" : "Free"
    }

    // MARK: - Initialization

    func initialize() {
        Task {
            await checkNotificationStatus()
            await refreshSubscriptionStatus()
        }
    }

    // MARK: - Notification Methods

    func checkNotificationStatus() async {
        isCheckingNotifications = true
        notificationStatus = await notificationService.getPermissionStatus()
        isCheckingNotifications = false
    }

    func handleNotificationButtonTap() {
        Task {
            switch notificationStatus {
            case .notDetermined:
                await requestNotificationPermission()
            case .denied:
                openNotificationSettings()
            case .authorized, .provisional:
                openNotificationSettings()
            }
        }
    }

    private func requestNotificationPermission() async {
        do {
            _ = try await notificationService.registerForPushNotifications()
            await checkNotificationStatus()
        } catch {
            await checkNotificationStatus()
        }
    }

    private func openNotificationSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Subscription Methods

    func refreshSubscriptionStatus() async {
        isSubscribed = subscriptionManager.isSubscribed
    }

    func restorePurchases() async {
        isRestoringPurchases = true
        await subscriptionCoordinator.restorePurchases()
        await refreshSubscriptionStatus()
        isRestoringPurchases = false
    }
}
