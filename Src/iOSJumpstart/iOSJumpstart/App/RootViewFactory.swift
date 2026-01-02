//
//  RootViewFactory.swift
//  iOSJumpstart
//
//

// ============================================================
// ROOT VIEW FACTORY
// ============================================================
//
// Abstracts view coordination and returns views for:
// • Authentication (page, sheet)
// • Logout confirmation
// • Account deletion
// • Paywall
//
// ============================================================

import SwiftUI
import Factory
import Authentication
import Subscription

struct RootViewFactory {

    // ════════════════════════════════════════════════════════
    // MARK: - Dependencies
    // ════════════════════════════════════════════════════════

    @Injected(\.authCoordinator) private var authCoordinator: any AuthCoordinator
    @Injected(\.subscriptionCoordinator) private var subscriptionCoordinator: SubscriptionCoordinatable

    // ════════════════════════════════════════════════════════
    // MARK: - Authentication Views
    // ════════════════════════════════════════════════════════

    func authenticationPage(onSuccess: @escaping () -> Void) -> AnyView {
        AnyView(authCoordinator.authenticationPage(onAuthSuccess: onSuccess))
    }

    func authenticationSheet(onSuccess: @escaping () -> Void) -> AnyView {
        AnyView(authCoordinator.authenticationSheet(onSuccess: onSuccess))
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Account Views
    // ════════════════════════════════════════════════════════

    func logoutSheet() -> AnyView {
        AnyView(authCoordinator.logoutSheet())
    }

    func deleteAccountSheet() -> AnyView {
        AnyView(authCoordinator.deleteAccountSheet())
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Subscription Views
    // ════════════════════════════════════════════════════════

    func paywallView() -> AnyView {
        subscriptionCoordinator.paywallView()
    }
}
