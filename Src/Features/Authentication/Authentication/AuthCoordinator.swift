//
//  AuthCoordinator.swift
//  Authentication
//
//

import UIKit
import SwiftUI
import Factory

// MARK: - Auth Views Protocol

/// Protocol that provides SwiftUI views for authentication flows
public protocol AuthCoordinator {
    associatedtype AuthSheet: View
    associatedtype AuthPageView: View
    associatedtype LogoutSheetView: View
    associatedtype DeleteAccountSheetView: View

    func authenticationSheet(onSuccess: @escaping () -> Void) -> AuthSheet
    func authenticationPage(onAuthSuccess: @escaping () -> Void) -> AuthPageView
    func logoutSheet() -> LogoutSheetView
    func deleteAccountSheet() -> DeleteAccountSheetView
}

// MARK: - Auth Views Implementation

/// Default implementation that provides SwiftUI views for authentication flows
struct AuthViews: AuthCoordinator {
    public init() {}

    /// Returns the authentication sheet view
    @ViewBuilder
    public func authenticationSheet(onSuccess: @escaping () -> Void) -> some View {
        AuthenticationSheet(onAuthSuccess: onSuccess)
    }

    /// Returns the full-screen authentication page view
    @ViewBuilder
    public func authenticationPage(onAuthSuccess: @escaping () -> Void) -> some View {
        AuthenticationPage(onAuthSuccess: onAuthSuccess)
    }

    /// Returns the logout confirmation sheet view
    @ViewBuilder
    public func logoutSheet() -> some View {
        LogoutSheet()
    }

    /// Returns the delete account confirmation sheet view
    @ViewBuilder
    public func deleteAccountSheet() -> some View {
        DeleteAccountSheet()
    }
}

// MARK: - Factory Registration

public extension Container {
    var authCoordinator: Factory<any AuthCoordinator> {
        self { AuthViews() }
    }
}
