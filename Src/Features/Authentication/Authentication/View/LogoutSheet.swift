//
//  LogoutSheet.swift
//  Authentication
//

import SwiftUI
import Common

struct LogoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AuthenticationViewModel()
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.Colors.primary.opacity(0.9))
                .padding(.top, 8)

            Text("Sign Out?")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            Text("You can always sign back in anytime.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(Theme.Typography.bodyBold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.Colors.card)
                        .foregroundColor(Theme.Colors.text)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.Colors.border, lineWidth: 1)
                        )
                }

                Button {
                    performLogout()
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isLoading ? "Signing Out" : "Sign Out")
                            .font(Theme.Typography.bodyBold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.Colors.primary)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isLoading)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }

    private func performLogout() {
        isLoading = true
        viewModel.logout {
            dismiss()
        }
    }
}

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            LogoutSheet()
        }
}
