//
//  AppNavigation.swift
//  iOSJumpstart
//
//  Unified navigation system: Routes, Navigator, and View Mapping
//

import SwiftUI

// ════════════════════════════════════════════════════════
// MARK: - Routes
// ════════════════════════════════════════════════════════

/// All possible navigation destinations in the app.
enum AppRoute: Hashable {
    case myProfile(userId: String? = nil)
    case settings(section: String? = nil)
    case showcase
    case more
}

// ════════════════════════════════════════════════════════
// MARK: - Navigator
// ════════════════════════════════════════════════════════

/// Manages navigation state for the entire app.
@MainActor
final class AppNavigator: ObservableObject {

    /// Navigation path for programmatic navigation
    @Published var navigationPath = NavigationPath()

    /// Currently selected tab index
    @Published var selectedTab = 0

    /// Navigate to a specific route
    func navigate(to route: AppRoute) {
        navigationPath.append(route)
    }

    /// Switch to a specific tab
    func navigateToTab(_ index: Int) {
        selectedTab = index
    }

    /// Pop all views and return to root
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}

// ════════════════════════════════════════════════════════
// MARK: - View Modifier
// ════════════════════════════════════════════════════════

/// ViewModifier that maps AppRoute cases to their corresponding views.
/// This is the single place where routes are connected to actual view implementations.
struct AppNavigatorModifier: ViewModifier {

    // MARK: - Callbacks

    let onDeleteAccount: () -> Void

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: AppRoute.self) { route in
                destinationView(for: route)
            }
    }

    // MARK: - Destination Mapping

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .myProfile(_):
            // Parameter currently unused, prepared for future enhancement
            MyProfileView(onDeleteAccount: onDeleteAccount)

        case .settings(_):
            // Parameter currently unused, prepared for future enhancement
            SettingsView(onDeleteAccount: onDeleteAccount)

        case .showcase:
            // Tab routes are handled via TabView selection binding
            EmptyView()

        case .more:
            // Tab routes are handled via TabView selection binding
            EmptyView()
        }
        // NO DEFAULT CASE - compiler will error if new route added without handling
    }
}

// ════════════════════════════════════════════════════════
// MARK: - View Extension
// ════════════════════════════════════════════════════════

extension View {
    /// Apply navigation destination mapping with required callbacks
    func withAppNavigator(onDeleteAccount: @escaping () -> Void) -> some View {
        modifier(AppNavigatorModifier(onDeleteAccount: onDeleteAccount))
    }
}
