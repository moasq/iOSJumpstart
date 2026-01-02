//
//  AuthenticationSheet.swift
//  Authentication
//
//


import SwiftUI
import Common

struct AuthenticationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AuthenticationViewModel

    var onAuthSuccess: (() -> Void)?

    init(onAuthSuccess: (() -> Void)? = nil) {
        self._viewModel = State(initialValue: .init())
        self.onAuthSuccess = onAuthSuccess
    }
    
    var body: some View {
        NavigationStack {
            content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.Colors.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Theme.Colors.text)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onChange(of: viewModel.isAuthenticated) { _, authenticated in
            if authenticated {
                // Call the success handler
                onAuthSuccess?()
                // Dismiss the sheet
                dismiss()
            }
        }
        .onAppear {
            // Set the success callback
            viewModel.onAuthSuccess = onAuthSuccess
        }
    }
    
    private var content: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Theme.Colors.primary)
                
                VStack(spacing: 8) {
                    Text("Welcome to iOSJumpstart")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)
                    
                    Text("Join our community of builders")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 24)
            
            // Auth Buttons
            VStack(spacing: 16) {
                AppleAuthButton(
                    isLoading: viewModel.authMethod == .apple,
                    action: {
                        guard viewModel.authMethod == .none else { return }
                        viewModel.signInWithApple()
                    }
                )
                
                AuthButton(
                    title: "Continue with Google",
                    icon: "google",
                    isSystemIcon: false,
                    isLoading: viewModel.authMethod == .google,
                    action: {
                        guard viewModel.authMethod == .none else { return }
                        viewModel.signInWithGoogle()
                    }
                )
            }
            .padding(.horizontal, 24)
            
            // Terms and Privacy
            VStack(spacing: 16) {
                Text("By continuing you agree to our")
                    .font(Theme.Typography.captionMedium)
                    .foregroundColor(Theme.Colors.textSecondary) +
                Text(" Terms ")
                    .font(Theme.Typography.link)
                    .foregroundColor(Theme.Colors.primary) +
                Text("and")
                    .font(Theme.Typography.captionMedium)
                    .foregroundColor(Theme.Colors.textSecondary) +
                Text(" Privacy Policy")
                    .font(Theme.Typography.link)
                    .foregroundColor(Theme.Colors.primary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

struct AppleAuthButton: View {
    @Environment(\.colorScheme) private var colorScheme
    var isLoading: Bool = false
    let action: () -> Void
    
    var body: some View {
        AppButton.Button(action: action) {
            HStack {
                Spacer()
                    .frame(width: 20)
                
                Spacer()
                // Logo always visible
                Image(systemName: "apple.logo")
                    .font(.system(size: 20))
                
                // Text centered
                Text("Continue with Apple")
                    .font(Theme.Typography.bodyBold)
                
                Spacer()
                // Loading indicator at trailing edge
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .dark ? Color.black : Color.white))
                        .frame(width: 20, height: 20)
                } else {
                    // Empty spacer to maintain layout when not loading
                    Spacer()
                        .frame(width: 20)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(colorScheme == .dark ? Color.white : Color.black)
            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.Colors.border, lineWidth: 1)
            )
            .shadowSmall()
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isLoading)
    }
}

struct AuthButton: View {
    let title: String
    let icon: String
    var isSystemIcon: Bool = true
    var isLoading: Bool = false
    let action: () -> Void
    
    var body: some View {
        AppButton.Button(action: action) {
            HStack {
                // Icon always visible
                Group {
                    Spacer()
                        .frame(width: 20)
                    
                    Spacer()
                    
                    if isSystemIcon {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                    } else {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                
                // Text centered
                Text(title)
                    .font(Theme.Typography.bodyBold)
                    .foregroundStyle(Theme.Colors.text)
                
                Spacer()
                
                // Loading indicator at trailing edge
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.text))
                        .frame(width: 20, height: 20)
                } else {
                    // Empty spacer to maintain layout when not loading
                    Spacer()
                        .frame(width: 20)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.Colors.card)
            .foregroundColor(Theme.Colors.text)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.Colors.border, lineWidth: 1)
            )
            .shadowSmall()
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isLoading)
    }
}

#Preview {
    AuthenticationSheet()
}
