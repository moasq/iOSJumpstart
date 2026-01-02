//
//  NotificationService.swift
//  iOSJumpstart
//

import Foundation
import UserNotifications

// MARK: - Permission Status

enum NotificationPermission: Sendable {
    case notDetermined
    case authorized
    case denied
    case provisional
}

// MARK: - Notification Error

enum NotificationError: Error, LocalizedError {
    case permissionDenied
    case registrationFailed(Error)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Notification permission was denied"
        case .registrationFailed(let error):
            return "Failed to register for notifications: \(error.localizedDescription)"
        }
    }
}

// MARK: - Notification Service Protocol

protocol NotificationService: Sendable {
    /// Initialize the notification service
    func initialize()

    /// Set APNs token for push notifications
    func setAPNsToken(_ token: Data)

    /// Get current permission status
    func getPermissionStatus() async -> NotificationPermission

    /// Register for push notifications and get device token
    func registerForPushNotifications() async throws -> String
}
