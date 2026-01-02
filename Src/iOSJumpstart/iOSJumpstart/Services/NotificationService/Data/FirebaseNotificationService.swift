//
//  FirebaseNotificationService.swift
//  iOSJumpstart
//
//  Firebase Cloud Messaging (FCM) implementation
//

import Foundation
import FirebaseMessaging
import UserNotifications
import UIKit

final class FirebaseNotificationService: NSObject, NotificationService, @unchecked Sendable {
    private var currentToken: String?

    override init() {
        super.init()
    }

    // MARK: - NotificationService

    func initialize() {
        Messaging.messaging().delegate = self
    }

    func setAPNsToken(_ token: Data) {
        Messaging.messaging().apnsToken = token
    }

    func getPermissionStatus() async -> NotificationPermission {
        let settings = await UNUserNotificationCenter.current().notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .provisional:
            return .provisional
        case .ephemeral:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }

    func registerForPushNotifications() async throws -> String {
        let permission = await getPermissionStatus()

        if permission != .authorized && permission != .provisional {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            guard granted else {
                throw NotificationError.permissionDenied
            }
        }

        // Register with APNs
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }

        // Get FCM token
        do {
            let token = try await Messaging.messaging().token()
            self.currentToken = token
            return token
        } catch {
            throw NotificationError.registrationFailed(error)
        }
    }
}

// MARK: - MessagingDelegate

extension FirebaseNotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        self.currentToken = token
        #if DEBUG
        print("[FCM] Token: \(token)")
        #endif
    }
}
