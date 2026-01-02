//
//  EarlyAccessBadge.swift
//  iOSJumpstart
//
//

import SwiftUI
import Common

struct EarlyAccessBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("EARLY ACCESS")
                .font(Theme.Typography.footnote)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.text)

            Text(AppConfiguration.App.version)
                .font(Theme.Typography.footnote)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Theme.Colors.card.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
    }
}

#Preview {
    EarlyAccessBadge()
}
