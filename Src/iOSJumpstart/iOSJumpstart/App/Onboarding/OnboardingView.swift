//
//  OnboardingView.swift
//  iOSJumpstart
//
//

// ============================================================
// ONBOARDING VIEW
// ============================================================
//
// Entry point for onboarding flow.
// Wraps OnboardingContainerView and handles completion persistence.
//
// STRUCTURE:
// OnboardingView (this file)
// └── OnboardingContainerView
//     ├── Pages/WelcomePage
//     ├── Pages/FeaturesPage
//     ├── Pages/PersonalizePage
//     ├── Pages/NotificationsPage
//     └── Pages/GetStartedPage
//
// ============================================================

import SwiftUI
import Common

struct OnboardingView: View {

    // MARK: - Properties

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var onComplete: () -> Void

    // MARK: - Body

    var body: some View {
        OnboardingContainerView(onComplete: completeOnboarding)
    }

    // MARK: - Actions

    private func completeOnboarding() {
        hasSeenOnboarding = true
        onComplete()
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
