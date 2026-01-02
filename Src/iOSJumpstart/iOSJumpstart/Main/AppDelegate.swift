//
//  AppDelegate.swift
//  iOSJumpstart
//
//

import UIKit
import FirebaseCore
import Factory

class AppDelegate: NSObject, UIApplicationDelegate {
    @Injected(\.notificationService) private var notificationService: NotificationService

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        notificationService.initialize()
        return true
    }

    // MARK: - Push Notifications

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        notificationService.setAPNsToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[Push] Failed to register: \(error)")
    }
}
