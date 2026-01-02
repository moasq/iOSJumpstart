//
//  OnboardingNavigationButtons.swift
//  iOSJumpstart
//
//

import SwiftUI
import Common

struct OnboardingNavigationButtons: View {
    let isFirstPage: Bool
    let isLastPage: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    let onComplete: () -> Void

    var body: some View {
        HStack {
            // Back button
            if !isFirstPage {
                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 16))
                        Text("Back")
                            .font(Theme.Typography.bodyBold)
                    }
                    .foregroundColor(Theme.Colors.text)
                    .frame(width: 100, height: 50)
                    .background(Theme.Colors.card.opacity(0.2))
                    .cornerRadius(25)
                }
            } else {
                Spacer()
                    .frame(width: 100)
            }

            Spacer()

            // Continue / Get Started button
            if !isLastPage {
                Button(action: onNext) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(Theme.Typography.bodyBold)
                        Image(systemName: "chevron.forward")
                    }
                    .foregroundColor(.white)
                    .frame(width: 160, height: 50)
                    .background(Theme.Colors.primary)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                }
            } else {
                Button(action: onComplete) {
                    HStack(spacing: 8) {
                        Text("Get Started")
                            .font(Theme.Typography.bodyBold)
                        Image(systemName: "arrow.forward")
                    }
                    .foregroundColor(.white)
                    .frame(width: 160, height: 50)
                    .background(Theme.Colors.primary)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    VStack(spacing: 40) {
        OnboardingNavigationButtons(
            isFirstPage: true,
            isLastPage: false,
            onBack: {},
            onNext: {},
            onComplete: {}
        )
        OnboardingNavigationButtons(
            isFirstPage: false,
            isLastPage: false,
            onBack: {},
            onNext: {},
            onComplete: {}
        )
        OnboardingNavigationButtons(
            isFirstPage: false,
            isLastPage: true,
            onBack: {},
            onNext: {},
            onComplete: {}
        )
    }
}
