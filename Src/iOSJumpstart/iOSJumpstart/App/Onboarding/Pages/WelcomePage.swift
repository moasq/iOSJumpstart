//
//  WelcomePage.swift
//  iOSJumpstart
//
//

// ============================================================
// PAGE 1: WELCOME
// ============================================================
//
// IMAGE NEEDED: "onboarding_welcome"
// Description: Rocket launching from a phone screen with stars
// and clouds in the background. Vibrant colors (blues, purples,
// orange accents). Modern flat design style.
//
// ============================================================

import SwiftUI
import Common

struct WelcomePage: View {

    var body: some View {
        GeometryReader { geometry in
            let imageSize = min(geometry.size.width * 0.7, geometry.size.height * 0.4)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 24)

                // Image
                Image("1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(16)

                Spacer()
                    .frame(height: 32)

                // Text Content
                VStack(spacing: 16) {
                    Text("Welcome to iOSJumpstart")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("Your journey to building amazing apps starts here.")
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
    WelcomePage()
}
