//
//  NotificationsPage.swift
//  iOSJumpstart
//
//

// ============================================================
// PAGE 4: NOTIFICATIONS
// ============================================================
//
// IMAGE NEEDED: "onboarding_notifications"
// Description: Phone with notification bubbles floating above it
// (messages, alerts, reminders). Friendly, inviting style with
// soft shadows.
//
// ============================================================

import SwiftUI
import Common
import Factory
import UIKit

struct NotificationsPage: View {

    // MARK: - Properties

    @State private var permissionStatus: NotificationPermission = .notDetermined
    @State private var isRequesting: Bool = false
    @Injected(\.notificationService) private var notificationService: NotificationService

    // MARK: - Computed Properties

    private var buttonTitle: String {
        switch permissionStatus {
        case .notDetermined:
            return "Enable Notifications"
        case .authorized, .provisional:
            return "Notifications Enabled"
        case .denied:
            return "Open Settings"
        }
    }

    private var isEnabled: Bool {
        permissionStatus == .authorized || permissionStatus == .provisional
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let imageSize = min(geometry.size.width * 0.7, geometry.size.height * 0.35)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 24)

                // Image
                Image("4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(16)

                Spacer()
                    .frame(height: 32)

                // Text Content
                VStack(spacing: 16) {
                    Text("Stay Updated")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("Enable notifications to never miss important updates.")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()
                    .frame(height: 32)

                // Permission Button
                Button {
                    handleButtonTap()
                } label: {
                    HStack(spacing: 8) {
                        if isRequesting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: isEnabled ? "checkmark.circle.fill" : "bell.badge")
                                .font(.system(size: 18))
                        }
                        Text(buttonTitle)
                            .font(Theme.Typography.bodyBold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isEnabled ? Color.green : Theme.Colors.primary)
                    .cornerRadius(14)
                }
                .disabled(isRequesting)
                .padding(.horizontal, 32)

                Spacer()
            }
            .frame(width: geometry.size.width)
        }
        .onAppear {
            Task {
                await checkPermissionStatus()
            }
        }
    }

    // MARK: - Methods

    private func checkPermissionStatus() async {
        permissionStatus = await notificationService.getPermissionStatus()
    }

    private func handleButtonTap() {
        switch permissionStatus {
        case .notDetermined:
            requestPermission()
        case .denied, .authorized, .provisional:
            openSettings()
        }
    }

    private func requestPermission() {
        isRequesting = true
        Task {
            do {
                _ = try await notificationService.registerForPushNotifications()
            } catch {
                // Permission denied or failed
            }
            await checkPermissionStatus()
            isRequesting = false
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    NotificationsPage()
}
