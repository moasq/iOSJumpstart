//
//  RootView.swift
//  iOSJumpstart
//
//

// ============================================================
// ROOT VIEW
// ============================================================
//
// Root of the app. Controls:
// • Auth flow (full-page vs sheet)
// • Onboarding overlay
// • Force update blocking
// • Network status banner
// • Sheet presentations
//
// ============================================================

import SwiftUI
import Factory
import Common

struct RootView: View {

    // ════════════════════════════════════════════════════════
    // MARK: - ViewModel & Factory
    // ════════════════════════════════════════════════════════

    @StateObject private var viewModel = RootViewModel()
    private let viewFactory = RootViewFactory()

    // ════════════════════════════════════════════════════════
    // MARK: - Navigation
    // ════════════════════════════════════════════════════════

    @StateObject private var navigator = AppNavigator()

    // ════════════════════════════════════════════════════════
    // MARK: - User Preferences
    // ════════════════════════════════════════════════════════

    @AppStorage("isDarkMode") private var isDarkMode = false

    #if DEBUG
    @State var hasSeenOnboarding = false
    #else
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    #endif

    // ════════════════════════════════════════════════════════
    // MARK: - Presentation State
    // ════════════════════════════════════════════════════════

    @State private var showAuthSheet = false
    @State private var showLogoutSheet = false
    @State private var showDeleteAccountSheet = false
    @State private var showPaywall = false
    @State private var forceUpdateInfo: AppUpdateInfo?

    // ════════════════════════════════════════════════════════
    // MARK: - Infrastructure
    // ════════════════════════════════════════════════════════

    @StateObject private var reviewManager = ReviewManager()
    @Environment(\.scenePhase) var scenePhase
    @Injected(\.networkMonitor) private var networkMonitor: NetworkMonitor
    @Injected(\.appUpdateChecker) private var appUpdateChecker: AppUpdateChecker

    // ════════════════════════════════════════════════════════
    // MARK: - Body
    // ════════════════════════════════════════════════════════

    var body: some View {
        VStack(spacing: 0) {
            networkBanner
            mainContent
        }
        .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
        .animation(.easeInOut(duration: 0.5), value: viewModel.authState)
        .environmentObject(navigator)
        .withDeepLinking(navigator: navigator)
        .task {
            await viewModel.checkAuthStatus()
        }
        .onChange(of: scenePhase) { _, newPhase in handleScenePhaseChange(newPhase) }
        .onChange(of: viewModel.authState) { _, newState in handleAuthStateChange(newState) }
        .onChange(of: viewModel.didSubscribe) { _, didSubscribe in if didSubscribe { showPaywall = false } }
        // ═══ Sheets ═══
        .sheet(isPresented: $showAuthSheet) {
            viewFactory.authenticationSheet(onSuccess: { showAuthSheet = false })
        }
        .sheet(isPresented: $showLogoutSheet) {
            viewFactory.logoutSheet()
        }
        .sheet(isPresented: $showDeleteAccountSheet) {
            viewFactory.deleteAccountSheet()
        }
        .sheet(isPresented: $showPaywall) {
            viewFactory.paywallView()
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Network Banner
    // ════════════════════════════════════════════════════════

    @ViewBuilder
    private var networkBanner: some View {
        if !networkMonitor.isConnected {
            NetworkBanner()
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Main Content
    // ════════════════════════════════════════════════════════

    @ViewBuilder
    private var mainContent: some View {
        ZStack {
            authStateContent
            onboardingOverlay
            forceUpdateOverlay
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Auth State Content
    // ════════════════════════════════════════════════════════

    @ViewBuilder
    private var authStateContent: some View {
        switch viewModel.authState {
        case .loading:
            loadingView

        case .result(let isAuthenticated):
            if isAuthenticated {
                authenticatedContent
            } else {
                unauthenticatedContent
            }
        }
    }

    // ── Authenticated: Main App ─────────────────────────────
    private var authenticatedContent: some View {
        NavigationStack(path: $navigator.navigationPath) {
            MainTabView(
                isDarkMode: $isDarkMode,
                onPresentAuth: { showAuthSheet = true },
                onPresentLogout: { showLogoutSheet = true },
                onPresentDeleteAccount: { showDeleteAccountSheet = true }
            )
            .withAppNavigator(onDeleteAccount: {
                showDeleteAccountSheet = true
            })
        }
        .transition(.opacity)
    }

    // ── Unauthenticated: Auth Page ──────────────────────────
    private var unauthenticatedContent: some View {
        viewFactory.authenticationPage(onSuccess: {})
            .transition(.opacity)
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Onboarding Overlay
    // ════════════════════════════════════════════════════════

    @ViewBuilder
    private var onboardingOverlay: some View {
        if !hasSeenOnboarding {
            OnboardingView(onComplete: {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                withAnimation(.easeInOut(duration: 0.5)) {
                    hasSeenOnboarding = true
                }
            })
            .transition(.opacity)
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Force Update Overlay
    // ════════════════════════════════════════════════════════

    @ViewBuilder
    private var forceUpdateOverlay: some View {
        if let updateInfo = forceUpdateInfo, updateInfo.isForceUpdateRequired {
            ForceUpdateView(updateInfo: updateInfo)
                .transition(.opacity)
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Loading View
    // ════════════════════════════════════════════════════════

    private var loadingView: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primary))
                .scaleEffect(1.5)
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: - State Change Handlers
    // ════════════════════════════════════════════════════════

    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            reviewManager.startSession()
            Task { await checkForUpdates() }
        case .inactive, .background:
            if reviewManager.endSession() {
                reviewManager.requestReview()
            }
        @unknown default:
            break
        }
    }

    private func handleAuthStateChange(_ newState: AuthState) {
        guard case .result(let isAuthenticated) = newState else { return }

        if isAuthenticated {
            viewModel.schedulePaywallPresentation { showPaywall = true }
        } else {
            navigator.popToRoot()
        }
    }

    private func checkForUpdates() async {
        guard let updateInfo = try? await appUpdateChecker.checkForUpdate(),
              updateInfo.isForceUpdateRequired else { return }

        await MainActor.run {
            withAnimation { forceUpdateInfo = updateInfo }
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Preview
// ════════════════════════════════════════════════════════

#Preview {
    RootView()
}
