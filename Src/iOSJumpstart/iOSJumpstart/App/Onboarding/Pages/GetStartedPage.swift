//
//  GetStartedPage.swift
//  iOSJumpstart
//
//

// ============================================================
// PAGE 5: GET STARTED
// ============================================================
//
// IMAGE NEEDED: "onboarding_complete"
// Description: Checkmark inside a circle with confetti/celebration
// elements around it. Celebratory mood with green/gold accents.
//
// ============================================================

import SwiftUI
import Common

struct GetStartedPage: View {

    var body: some View {
        GeometryReader { geometry in
            let imageSize = min(geometry.size.width * 0.7, geometry.size.height * 0.4)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 24)

                // Image
                Image("5")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(16)

                Spacer()
                    .frame(height: 32)

                // Text Content
                VStack(spacing: 16) {
                    Text("You're All Set!")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("Start building your next great app today.")
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
    GetStartedPage()
}
