//
//  PlaceholderTabView.swift
//  iOSJumpstart
//
//  Created by Claude on 12/25/25.
//

import SwiftUI
import Common

struct PlaceholderTabView: View {
    let title: String
    let icon: String
    let description: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 72))
                .foregroundColor(Theme.Colors.primary.opacity(0.3))

            VStack(spacing: 12) {
                Text(title)
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.text)

                Text(description)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

#Preview {
    PlaceholderTabView(
        title: "Home",
        icon: "house.fill",
        description: "Your main content will go here"
    )
}
