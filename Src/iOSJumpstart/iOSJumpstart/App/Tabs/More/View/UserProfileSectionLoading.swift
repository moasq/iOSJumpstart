//
//  UserProfileSectionLoading.swift
//  iOSJumpstart
//
//

import Common
import SwiftUI

struct UserProfileSectionLoading: View {
    var body: some View {
        HStack(spacing: 16) {
            // Profile image placeholder
            Circle()
                .fill(Theme.Colors.border.opacity(0.3))
                .frame(width: 56, height: 56)

            // User details placeholder
            VStack(alignment: .leading, spacing: 4) {
                Rectangle()
                    .fill(Theme.Colors.border.opacity(0.3))
                    .frame(height: 18)
                    .cornerRadius(4)

                Rectangle()
                    .fill(Theme.Colors.border.opacity(0.3))
                    .frame(width: 100, height: 14)
                    .cornerRadius(4)
            }

            Spacer()

            // Chevron placeholder
            Rectangle()
                .fill(Theme.Colors.border.opacity(0.3))
                .frame(width: 8, height: 14)
                .cornerRadius(2)
        }
        .padding()
        .background(Theme.Colors.card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
        .shadowSmall()
    }
}



