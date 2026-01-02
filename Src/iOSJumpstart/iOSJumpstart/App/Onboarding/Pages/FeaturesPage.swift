//
//  FeaturesPage.swift
//  iOSJumpstart
//
//

// ============================================================
// PAGE 2: FEATURES
// ============================================================
//
// IMAGE NEEDED: "onboarding_features"
// Description: Grid of app feature icons (lock for auth, credit
// card for payments, bell for notifications, gear for settings)
// floating around a central phone. Clean, minimal style.
//
// ============================================================

import SwiftUI
import Common

struct FeaturesPage: View {

    var body: some View {
        GeometryReader { geometry in
            let imageSize = min(geometry.size.width * 0.7, geometry.size.height * 0.4)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 24)

                // Image
                Image("2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(16)

                Spacer()
                    .frame(height: 32)

                // Text Content
                VStack(spacing: 16) {
                    Text("Powerful Features")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("Authentication, subscriptions, and more — all ready to use.")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()
            }
            .frame(width: geometry.size.width)
        }
    }
}

#Preview {
    FeaturesPage()
}
