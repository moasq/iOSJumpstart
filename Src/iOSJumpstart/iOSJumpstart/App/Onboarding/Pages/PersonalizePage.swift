//
//  PersonalizePage.swift
//  iOSJumpstart
//
//

// ============================================================
// PAGE 3: PERSONALIZE
// ============================================================
//
// IMAGE NEEDED: "onboarding_personalize"
// Description: Paint palette with a brush, alongside a phone
// showing color swatches and theme options. Warm, creative colors.
//
// ============================================================

import SwiftUI
import Common

struct PersonalizePage: View {

    var body: some View {
        GeometryReader { geometry in
            let imageSize = min(geometry.size.width * 0.7, geometry.size.height * 0.4)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 24)

                // Image
                Image("3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(16)

                Spacer()
                    .frame(height: 32)

                // Text Content
                VStack(spacing: 16) {
                    Text("Make It Yours")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("Customize themes, colors, and preferences to match your style.")
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
    PersonalizePage()
}
