//
//  RootViewModel.swift
//  iOSJumpstart
//
//

// ============================================================
// ROOT VIEW MODEL
// ============================================================
//
// Single ViewModel for RootView. Handles:
// • Authentication state management (via published authState)
// • Event subscriptions (login, logout, subscription)
// • Push notification registration
// • Paywall scheduling
//
// Presentation state (@State) is owned by RootView, not this ViewModel.
// View observes @Published properties to react to state changes.
//
// ============================================================

import Foundation
import SwiftUI
import Factory
import Common
import Events
import Authentication
import Subscription

// ============================================================
// MARK: - Auth State
// ============================================================

enum AuthState: Equatable {
    case loading
    case result(isAuthenticated: Bool)

    var isAuthenticated: Bool {
        if case .result(let authenticated) = self { return authenticated }
        return false
    }
}

// ============================================================
// MARK: - Root View Model
// ============================================================

@MainActor
final class RootViewModel: ObservableObject {

    // ════════════════════════════════════════════════════════
    // MARK: - Published State
    // ════════════════════════════════════════════════════════

    @Published private(set) var authState: AuthState = .loading
    @Published private(set) var didSubscribe = false

    // ════════════════════════════════════════════════════════
    // MARK: - Dependencies
    // ════════════════════════════════════════════════════════

    @Injected(\.authStatusRepository) private var authRepository: AuthStatusRepository
    @Injected(\.eventViewModel) private var eventViewModel: EventViewModel
    @Injected(\.subscriptionManager) private var subscriptionManager: SubscriptionManager
    @Injected(\.notificationService) private var notificationService: NotificationService

    // ════════════════════════════════════════════════════════
    // MARK: - Configuration
    // ════════════════════════════════════════════════════════

    private let paywallDelayAfterLogin: TimeInterval? = 3.0

    // ════════════════════════════════════════════════════════
    // MARK: - Initialization
    // ════════════════════════════════════════════════════════

    init() {
        subscribeToEvents()
    }

    deinit {
        Container.shared.eventViewModel().unsubscribe(self)
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Auth Check
    // ════════════════════════════════════════════════════════

    func checkAuthStatus() async {
        authState = .loading
        let isAuthenticated = await authRepository.isAuthenticated()

        if isAuthenticated {
            eventViewModel.emit(.userLoggedIn)
        } else {
            authState = .result(isAuthenticated: false)
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Paywall
    // ════════════════════════════════════════════════════════

    func schedulePaywallPresentation(present: @escaping () -> Void) {
        guard let delay = paywallDelayAfterLogin else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self, !subscriptionManager.isSubscribed else { return }
            present()
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Event Handling
    // ════════════════════════════════════════════════════════

    private func subscribeToEvents() {
        eventViewModel.subscribe(
            for: self,
            to: [.authentication, .subscription],
            handler: { [weak self] event in
                Task { @MainActor in self?.handleEvent(event) }
            }
        )
    }

    private func handleEvent(_ event: EventViewModel.Event) {
        switch event {
        case .userLoggedIn:
            withAnimation(.easeInOut(duration: 0.5)) {
                authState = .result(isAuthenticated: true)
            }
            // TODO: Notification permission now handled in Showcase tab
            // Task { await registerForPushNotifications() }

        case .userLoggedOut:
            withAnimation(.easeInOut(duration: 0.5)) {
                authState = .result(isAuthenticated: false)
            }

        case .userSubscribed:
            didSubscribe = true

        default:
            break
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Push Notifications
    // ════════════════════════════════════════════════════════

    private func registerForPushNotifications() async {
        do {
            _ = try await notificationService.registerForPushNotifications()
        } catch {
            #if DEBUG
            print("[RootViewModel] Push registration failed: \(error)")
            #endif
        }
    }
}
