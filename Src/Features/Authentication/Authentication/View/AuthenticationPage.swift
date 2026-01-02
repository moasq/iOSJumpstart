//
//  AuthenticationPage.swift
//  Authentication
//
//  Full-screen authentication page shown after onboarding.
//

import SwiftUI
import Common

public struct AuthenticationPage: View {
    @State private var viewModel: AuthenticationViewModel

    var onAuthSuccess: () -> Void

    public init(onAuthSuccess: @escaping () -> Void) {
        self._viewModel = State(initialValue: .init())
        self.onAuthSuccess = onAuthSuccess
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Header with icon and welcome text
                    headerSection
                        .padding(.bottom, 48)

                    // Auth buttons section
                    VStack(spacing: 16) {
                        AppleAuthButton(
                            isLoading: viewModel.authMethod == .apple,
                            action: {
                                guard viewModel.authMethod == .none else { return }
                                viewModel.signInWithApple { success in
                                    if success { onAuthSuccess() }
                                }
                            }
                        )

                        AuthButton(
                            title: "Continue with Google",
                            icon: "google",
                            isSystemIcon: false,
                            isLoading: viewModel.authMethod == .google,
                            action: {
                                guard viewModel.authMethod == .none else { return }
                                viewModel.signInWithGoogle { success in
                                    if success { onAuthSuccess() }
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // Terms and Privacy
                    termsSection
                        .padding(.bottom, 32)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(Theme.Colors.primary)

            VStack(spacing: 8) {
                Text("Welcome")
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.text)

                Text("Sign in to unlock all features and sync your data")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }

    private var termsSection: some View {
        VStack(spacing: 8) {
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
    }
}

#Preview {
    AuthenticationPage(
        onAuthSuccess: {}
    )
}
