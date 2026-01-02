//
//  OnboardingPageIndicator.swift
//  iOSJumpstart
//
//

import SwiftUI
import Common

struct OnboardingPageIndicator: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ?
                          Theme.Colors.primary :
                          Theme.Colors.border)
                    .frame(
                        width: currentPage == index ? 24 : 8,
                        height: 8
                    )
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }
}

#Preview {
    OnboardingPageIndicator(currentPage: 2, totalPages: 5)
}
