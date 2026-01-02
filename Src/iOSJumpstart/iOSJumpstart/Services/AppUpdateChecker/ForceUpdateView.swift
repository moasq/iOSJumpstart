//
//  ForceUpdateView.swift
//  iOSJumpstart
//
//  Created by Claude on 1/1/26.
//

import SwiftUI
import Common

struct ForceUpdateView: View {
    let updateInfo: AppUpdateInfo

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: "arrow.down.app")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.primary)

            // Title
            Text("Update Required")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.text)

            // Message
            Text("A new version of \(AppConfiguration.App.name) is available. Please update to continue using the app.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Version info
            VStack(spacing: 4) {
                Text("Current version: \(updateInfo.currentVersion)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                Text("Latest version: \(updateInfo.latestVersion)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            Spacer()

            // Update button
            Button {
                UIApplication.shared.open(updateInfo.updateURL)
            } label: {
                Text("Update Now")
                    .font(Theme.Typography.bodyBold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.Colors.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

#Preview {
    ForceUpdateView(
        updateInfo: AppUpdateInfo(
            currentVersion: "1.0.0",
            latestVersion: "2.0.0",
            updateURL: URL(string: "https://apps.apple.com")!,
            isUpdateAvailable: true,
            isForceUpdateRequired: true
        )
    )
}
