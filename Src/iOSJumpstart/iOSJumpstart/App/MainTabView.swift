//
//  MainTabView.swift
//  iOSJumpstart
//
//

import SwiftUI
import Common

struct MainTabView: View {
    @Binding var isDarkMode: Bool

    // ════════════════════════════════════════════════════════
    // MARK: - Callbacks (from RootView)
    // ════════════════════════════════════════════════════════

    let onPresentAuth: () -> Void
    let onPresentLogout: () -> Void
    let onPresentDeleteAccount: () -> Void

    // ════════════════════════════════════════════════════════
    // MARK: - Navigation
    // ════════════════════════════════════════════════════════

    @EnvironmentObject private var navigator: AppNavigator

    // ════════════════════════════════════════════════════════
    // MARK: - Body
    // ════════════════════════════════════════════════════════

    var body: some View {
        TabView(selection: $navigator.selectedTab) {
            ShowcaseTab()
                .tag(0)
                .tabItem {
                    Label("Showcase", systemImage: "star.fill")
                }

            MoreTab(
                isDarkMode: $isDarkMode,
                onAuthPresent: onPresentAuth,
                onLogoutPresent: onPresentLogout,
                onDeleteAccountPresent: onPresentDeleteAccount,
                onMyProfileClicked: { navigator.navigate(to: .myProfile()) }
            )
            .tag(1)
            .tabItem {
                Label("More", systemImage: "ellipsis")
            }
        }
        .tint(Theme.Colors.primary)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .animation(.spring(duration: 0.3), value: isDarkMode)
    }
}

#Preview {
    MainTabView(
        isDarkMode: .constant(false),
        onPresentAuth: {},
        onPresentLogout: {},
        onPresentDeleteAccount: {}
    )
    .environmentObject(AppNavigator())
}
