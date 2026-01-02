//
//  SettingsView.swift
//  iOSJumpstart
//
//  Placeholder settings view for deep link navigation.
//

import SwiftUI
import Common

struct SettingsView: View {

    // ════════════════════════════════════════════════════════
    // MARK: - Callbacks
    // ════════════════════════════════════════════════════════

    let onDeleteAccount: () -> Void

    // ════════════════════════════════════════════════════════
    // MARK: - Body
    // ════════════════════════════════════════════════════════

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                placeholderSection
            }
            .padding()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .background(Theme.Colors.background.ignoresSafeArea())
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Header Section
    // ════════════════════════════════════════════════════════

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 60))
                .foregroundStyle(Theme.Colors.primary)

            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Theme.Colors.text)

            Text("Configure your app preferences")
                .font(.subheadline)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .padding(.top, 32)
    }

    // ════════════════════════════════════════════════════════
    // MARK: - Placeholder Section
    // ════════════════════════════════════════════════════════

    private var placeholderSection: some View {
        VStack(spacing: 16) {
            Text("Settings Coming Soon")
                .font(.headline)
                .foregroundStyle(Theme.Colors.text)

            Text("This is a placeholder view for the settings screen. Add your app-specific settings here.")
                .font(.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Divider()
                .padding(.vertical, 8)

            Button(role: .destructive, action: onDeleteAccount) {
                Label("Delete Account", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.Colors.card)
        )
    }
}

#Preview {
    NavigationStack {
        SettingsView(onDeleteAccount: {})
    }
}
