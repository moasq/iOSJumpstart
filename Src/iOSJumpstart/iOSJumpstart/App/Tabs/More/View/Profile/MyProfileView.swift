//
//  MyProfileView.swift
//  iOSJumpstart
//

import SwiftUI
import PhotosUI
import Common
import NukeUI

struct MyProfileView: View {
    @StateObject private var viewModel = MyProfileViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    @State private var showRemoveAlert = false

    let onDeleteAccount: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else {
                contentView
            }
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        if await viewModel.saveProfile() {
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(Theme.Colors.primary)
                    } else {
                        Text("Save")
                    }
                }
                .foregroundColor(Theme.Colors.primary)
                .disabled(!viewModel.canSave || viewModel.isSaving)
                .opacity(viewModel.canSave && !viewModel.isSaving ? 1 : 0.5)
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "An error occurred")
        }
        .alert("Remove Photo", isPresented: $showRemoveAlert) {
            Button("Remove", role: .destructive) {
                Task {
                    await viewModel.removeAvatar()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to remove your profile photo?")
        }
        .overlay {
            if viewModel.isRemovingAvatar {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
        .task {
            await viewModel.loadProfile()
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    viewModel.selectedImageData = data
                }
            }
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primary))
            Text("Loading profile...")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.top, 8)
        }
    }

    // MARK: - Content View
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Avatar Section
                avatarSection
                    .padding(.top, 20)

                // Form Fields
                formSection

                Spacer(minLength: 40)

                // Delete Account Button
                deleteAccountButton
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Avatar Section
    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                // Avatar image (not tappable)
                avatarImage
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Theme.Colors.border, lineWidth: 2)
                    )

                // Badge icon - conditional behavior
                if viewModel.hasAvatar {
                    // Has avatar: Menu with Edit/Remove
                    Menu {
                        Button {
                            showPhotoPicker = true
                        } label: {
                            Label("Edit Photo", systemImage: "photo")
                        }
                        Button(role: .destructive) {
                            showRemoveAlert = true
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    } label: {
                        badgeIcon(systemName: "pencil")
                    }
                } else {
                    // No avatar: Direct photo picker
                    Button {
                        showPhotoPicker = true
                    } label: {
                        badgeIcon(systemName: "photo.badge.plus")
                    }
                }
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedItem,
                matching: .images
            )

            Text(viewModel.hasAvatar ? "Tap to edit photo" : "Tap to add photo")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }

    private func badgeIcon(systemName: String) -> some View {
        Circle()
            .fill(Theme.Colors.primary)
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: systemName)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            )
            .offset(x: 4, y: 4)
    }

    @ViewBuilder
    private var avatarImage: some View {
        if let imageData = viewModel.selectedImageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if let avatarURL = viewModel.avatarURL {
            LazyImage(url: avatarURL) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if state.isLoading {
                    loadingAvatar
                } else {
                    placeholderAvatar
                }
            }
        } else {
            placeholderAvatar
        }
    }

    private var placeholderAvatar: some View {
        ZStack {
            Circle()
                .fill(Theme.Colors.primary.opacity(0.1))

            if !viewModel.displayName.isEmpty {
                Text(String(viewModel.displayName.prefix(1).uppercased()))
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(Theme.Colors.primary)
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.Colors.primary)
            }
        }
    }

    private var loadingAvatar: some View {
        ZStack {
            Circle()
                .fill(Theme.Colors.card)

            ProgressView()
                .tint(Theme.Colors.primary)
        }
    }

    // MARK: - Form Section
    private var formSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile Information")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.text)

            VStack(alignment: .leading, spacing: 8) {
                Text("Display Name")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)

                TextField("Enter your name", text: $viewModel.displayName)
                    .font(Theme.Typography.callout)
                    .padding()
                    .background(Theme.Colors.card)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.Colors.border, lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Theme.Colors.card)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
        .shadowSmall()
    }

    // MARK: - Delete Account Button
    private var deleteAccountButton: some View {
        Button {
            onDeleteAccount()
        } label: {
            HStack {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                Text("Delete Account")
                    .font(Theme.Typography.bodyBold)
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    NavigationStack {
        MyProfileView(onDeleteAccount: {})
    }
}
