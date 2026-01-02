//
//  ShowcaseTab.swift
//  iOSJumpstart
//
//

import SwiftUI
import Common
import Factory
import Subscription

struct ShowcaseTab: View {

    // MARK: - Properties

    @StateObject private var viewModel = ShowcaseViewModel()
    @State private var showPaywall = false

    @Injected(\.subscriptionCoordinator) private var subscriptionCoordinator: SubscriptionCoordinatable

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Notification Card
                    notificationCard

                    // Paywall Card
                    paywallCard

                    // Subscription Status Card
                    subscriptionCard
                }
                .padding()
            }
        }
        .background(Theme.Colors.background)
        .sheet(isPresented: $showPaywall) {
            subscriptionCoordinator.paywallView()
        }
        .onAppear {
            viewModel.initialize()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                await viewModel.checkNotificationStatus()
                await viewModel.refreshSubscriptionStatus()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Showcase")
                    .font(Theme.Typography.title3)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 16)

            Divider()
        }
        .background(Theme.Colors.background)
    }

    // MARK: - Notification Card

    private var notificationCard: some View {
        ShowcaseCard(
            icon: viewModel.isNotificationEnabled ? "bell.fill" : "bell.slash",
            iconColor: viewModel.isNotificationEnabled ? .green : Theme.Colors.textSecondary,
            title: "Notifications",
            subtitle: viewModel.notificationStatusText
        ) {
            VStack(spacing: 12) {
                Text("Request notification permissions from users. The button below demonstrates the native iOS permission dialog.")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    viewModel.handleNotificationButtonTap()
                } label: {
                    HStack {
                        if viewModel.isCheckingNotifications {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: viewModel.isNotificationEnabled ? "checkmark.circle.fill" : "bell.badge")
                                .font(.system(size: 16))
                        }
                        Text(viewModel.notificationButtonTitle)
                            .font(Theme.Typography.bodyBold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(viewModel.isNotificationEnabled ? Color.green : Theme.Colors.primary)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isCheckingNotifications)
            }
        }
    }

    // MARK: - Paywall Card

    private var paywallCard: some View {
        ShowcaseCard(
            icon: "creditcard.fill",
            iconColor: Theme.Colors.primary,
            title: "Paywall",
            subtitle: "RevenueCat Integration"
        ) {
            VStack(spacing: 12) {
                Text("Present the paywall to showcase subscription offerings. Powered by RevenueCat for seamless in-app purchases.")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                        Text("Show Paywall")
                            .font(Theme.Typography.bodyBold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.Colors.primary)
                    .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Subscription Card

    private var subscriptionCard: some View {
        ShowcaseCard(
            icon: viewModel.isSubscribed ? "crown.fill" : "person.fill",
            iconColor: viewModel.isSubscribed ? .orange : Theme.Colors.textSecondary,
            title: "Subscription Status",
            subtitle: viewModel.subscriptionStatusText,
            badge: viewModel.isSubscribed ? "PRO" : nil
        ) {
            VStack(spacing: 12) {
                Text(viewModel.isSubscribed
                     ? "You're a Pro member! Enjoy all premium features."
                     : "Upgrade to Pro to unlock all premium features and support development.")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !viewModel.isSubscribed {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 16))
                            Text("Upgrade to Pro")
                                .font(Theme.Typography.bodyBold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.Colors.primary)
                        .cornerRadius(12)
                    }
                }

                Button {
                    Task {
                        await viewModel.restorePurchases()
                    }
                } label: {
                    HStack {
                        if viewModel.isRestoringPurchases {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primary))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14))
                        }
                        Text("Restore Purchases")
                            .font(Theme.Typography.body)
                    }
                    .foregroundColor(Theme.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.Colors.primary.opacity(0.1))
                    .cornerRadius(12)
                }
                .disabled(viewModel.isRestoringPurchases)
            }
        }
    }
}

// MARK: - Showcase Card Component

struct ShowcaseCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var badge: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconColor.opacity(0.1))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.text)

                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }

                    Text(subtitle)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                Spacer()
            }

            // Content
            content()
        }
        .padding()
        .background(Theme.Colors.card)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
        .shadowSmall()
    }
}

#Preview {
    ShowcaseTab()
}
