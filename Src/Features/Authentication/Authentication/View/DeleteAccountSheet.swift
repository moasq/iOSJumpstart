//
//  DeleteAccountSheet.swift
//  Authentication
//

import SwiftUI
import Common

public struct DeleteAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AuthenticationViewModel()
    @State private var isLoading = false
    @State private var error: Error?

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trash.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.red.opacity(0.9))
                .padding(.top, 8)

            Text("Delete Account?")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            Text("This will permanently delete your account and all data.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let error {
                Text(error.localizedDescription)
                    .font(Theme.Typography.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

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
                    deleteAccount()
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isLoading ? "Deleting" : "Delete")
                            .font(Theme.Typography.bodyBold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isLoading)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }

    private func deleteAccount() {
        isLoading = true
        error = nil
        Task {
            do {
                try await viewModel.deleteAccount()
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            DeleteAccountSheet()
        }
}
