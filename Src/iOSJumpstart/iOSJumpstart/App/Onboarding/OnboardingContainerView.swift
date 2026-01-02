//
//  OnboardingContainerView.swift
//  iOSJumpstart
//
//

// ============================================================
// ONBOARDING CONTAINER
// ============================================================
//
// Coordinator view that manages navigation between onboarding pages.
// Each page is a self-contained view in the Pages/ folder.
//
// CUSTOMIZATION:
// - Add/remove pages in the TabView
// - Adjust totalPages constant when changing page count
// - Modify header/footer as needed
//
// ============================================================

import SwiftUI
import Common

struct OnboardingContainerView: View {

    // MARK: - Properties

    @State private var currentPage = 0
    private let totalPages = 5

    var onComplete: () -> Void

    // MARK: - Computed Properties

    private var isFirstPage: Bool { currentPage == 0 }
    private var isLastPage: Bool { currentPage == totalPages - 1 }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerSection
                        .frame(height: 60)

                    contentSection(geometry: geometry)
                        .frame(height: geometry.size.height - 180)

                    footerSection
                        .frame(height: 120)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack {
            HStack {
                EarlyAccessBadge()
                    .padding(.leading, 20)
                Spacer()
            }

            if currentPage >= 2 {
                HStack {
                    Spacer()
                    Button {
                        onComplete()
                    } label: {
                        Text("Skip")
                            .font(Theme.Typography.callout)
                            .foregroundColor(Theme.Colors.text)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Theme.Colors.card.opacity(0.1))
                            .cornerRadius(16)
                    }
                    .padding(.trailing, 20)
                }
            }
        }
    }

    // MARK: - Content

    private func contentSection(geometry: GeometryProxy) -> some View {
        TabView(selection: $currentPage) {
            WelcomePage()
                .tag(0)

            FeaturesPage()
                .tag(1)

            PersonalizePage()
                .tag(2)

            NotificationsPage()
                .tag(3)

            GetStartedPage()
                .tag(4)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .animation(.easeInOut, value: currentPage)
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 32) {
            OnboardingPageIndicator(
                currentPage: currentPage,
                totalPages: totalPages
            )

            OnboardingNavigationButtons(
                isFirstPage: isFirstPage,
                isLastPage: isLastPage,
                onBack: { currentPage -= 1 },
                onNext: { currentPage += 1 },
                onComplete: onComplete
            )
        }
    }
}

#Preview {
    OnboardingContainerView(onComplete: {})
}
