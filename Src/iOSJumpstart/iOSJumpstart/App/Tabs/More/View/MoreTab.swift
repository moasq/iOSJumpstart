//
//  MoreTab.swift
//  iOSJumpstart
//
//

import SwiftUI
import Common
import WebKit
import MessageUI
import Combine
import Subscription

// MARK: - PageInfo
struct PageInfo: Identifiable, Hashable {
    var id = UUID()
    var url: String
    var title: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PageInfo, rhs: PageInfo) -> Bool {
        return lhs.id == rhs.id
    }
}

struct MoreTab: View {
    @Binding var isDarkMode: Bool
    @StateObject var viewModel: MoreViewModel = .init()
    @State private var currentPage: PageInfo? = nil
    @State private var isShowingMailView = false

    let onAuthPresent: () -> Void
    let onLogoutPresent: () -> Void
    let onDeleteAccountPresent: () -> Void
    let onMyProfileClicked: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Authentication section - either sign in button or user profile
                    if viewModel.myProfileInfo.isLoading || viewModel.myProfileInfo.isNotInitiated {
                        UserProfileSectionLoading()
                            .padding(.horizontal)
                    } else if viewModel.myProfileInfo.isFailure {
                        // Error state - show retry option
                        ProfileErrorSection(onRetry: { Task { await viewModel.retry() } })
                            .padding(.horizontal)
                    } else if viewModel.isAuthenticated {
                        // Authenticated user - show profile
                        Button {
                            self.onMyProfileClicked()
                        } label: {
                            if let profile = viewModel.myProfileInfo.value,
                               let userInfo = profile?.toUserSummaryInfo(email: viewModel.userEmail) {
                                UserProfileSection(userInfo: userInfo, isSubscribed: viewModel.isSubscribed)
                            } else {
                                // Fallback for nil profile
                                let name = viewModel.userEmail.components(separatedBy: "@").first ?? "User"
                                UserProfileSection(userInfo: UserSummaryInfo(profilePhoto: nil, email: viewModel.userEmail, name: name), isSubscribed: viewModel.isSubscribed)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // Not authenticated
                        SignInButton(onAuthPress: onAuthPresent)
                            .padding(.horizontal)
                    }

                    VStack(spacing: 20) {
                        // Settings section
                        SectionCard(title: "Settings", items: settingsItems, isDarkMode: $isDarkMode)

                        // Support section
                        SectionCard(title: "Support", items: supportItems, isDarkMode: $isDarkMode)

                        // Account actions section - shown when authenticated
                        if viewModel.isAuthenticated {
                            SectionCard(title: "Account", items: accountItems, isDarkMode: $isDarkMode)
                        }

                        // App version
                        Text("Version \(AppConfiguration.App.version)")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .refreshable {
                await self.viewModel.refresh()
            }
        }
        .background(Theme.Colors.background)
        .fullScreenCover(item: $currentPage) { page in
            WebView(pageInfo: page)
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: $isShowingMailView)
        }
        .checkMailAvailability(isShowing: $isShowingMailView)
        .onAppear {
            viewModel.initialize()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                await viewModel.checkNotificationStatus()
                viewModel.refreshSubscriptionStatus()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("More")
                    .font(Theme.Typography.title3)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            
            Divider()
        }
        .background(Theme.Colors.background)
    }
    
    private var settingsItems: [MenuItem] {
        [
            .init(icon: "moon",
                  title: "Dark Mode",
                  hasToggle: true,
                  isToggled: isDarkMode,
                  showChevron: false),
            .init(icon: viewModel.isNotificationsEnabled ? "bell" : "bell.slash",
                  title: "Notifications",
                  subtitle: viewModel.isNotificationsEnabled ? nil : "Tap to enable in Settings",
                  hasToggle: true,
                  isToggled: viewModel.isNotificationsEnabled,
                  isToggleReadOnly: true,
                  action: { [weak viewModel] in
                      viewModel?.openNotificationSettings()
                  },
                  showChevron: false)
        ]
    }
    
    private var supportItems: [MenuItem] {
        [
            .init(icon: "star", title: "Rate App", action: {
                viewModel.openAppStoreReview()
            }),
            .init(icon: "square.and.arrow.up", title: "Share App", action: {
                viewModel.shareApp()
            }),
            .init(icon: "info.circle", title: "About", action: {
                currentPage = PageInfo(url: "https://www.iosjumpstart.com/about", title: "About")
            }),
            .init(icon: "doc.text", title: "Terms of Service", action: {
                currentPage = PageInfo(url: "https://www.iosjumpstart.com/terms", title: "Terms of Service")
            }),
            .init(icon: "lock", title: "Privacy Policy", action: {
                currentPage = PageInfo(url: "https://www.iosjumpstart.com/privacy", title: "Privacy Policy")
            }),
            .init(icon: "envelope", title: "Contact Us", action: {
                isShowingMailView = true
            })
        ]
    }
    
    private var accountItems: [MenuItem] {
        [
            .init(icon: "rectangle.portrait.and.arrow.right",
                  title: "Logout",
                  action: onLogoutPresent)
        ]
    }
}

struct SignInButton: View {
    let onAuthPress: () -> Void

    var body: some View {
        AppButton.Button {
            onAuthPress()
        } label: {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Theme.Colors.text)

                Text("Sign in")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.textSecondary)
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
        .buttonStyle(ScaleButtonStyle())
    }
}

struct GuestUserSection: View {
    let onAuthPress: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.Colors.textSecondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Guest User")
                        .font(Theme.Typography.title3)
                        .foregroundColor(Theme.Colors.text)

                    Text("Sign in to sync your data")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                Spacer()
            }

            Button {
                onAuthPress()
            } label: {
                Text("Sign in with account")
                    .font(Theme.Typography.bodyBold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.Colors.primary)
                    .cornerRadius(8)
            }
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

struct ProfileErrorSection: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Error loading profile")
                        .font(Theme.Typography.title3)
                        .foregroundColor(Theme.Colors.text)

                    Text("Tap to retry")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.Colors.primary)
            }
        }
        .padding()
        .background(Theme.Colors.card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
        .shadowSmall()
        .onTapGesture {
            onRetry()
        }
    }
}

struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    var isSystemIcon: Bool = true
    let title: String
    var subtitle: String? = nil
    var hasToggle: Bool = false
    var isToggled: Bool = false
    var isToggleReadOnly: Bool = false  // When true, toggle is display-only
    var action: (() -> Void)? = nil
    var showChevron: Bool = true
}

struct SectionCard: View {
    let title: String
    let items: [MenuItem]
    @Binding var isDarkMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.text)
                .padding(.horizontal, 8)
            
            VStack(spacing: 0) {
                ForEach(items) { item in
                    MenuRow(item: item, isDarkMode: item.hasToggle ? $isDarkMode : .constant(false))
                    
                    if item.id != items.last?.id {
                        Divider()
                            .background(Theme.Colors.border)
                            .padding(.leading, 48)
                    }
                }
            }
            .background(Theme.Colors.card)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.Colors.border, lineWidth: 1)
            )
            .shadowSmall()
        }
    }
}

struct MenuRow: View {
    let item: MenuItem
    @Binding var isDarkMode: Bool

    var body: some View {
        Button {
            // For read-only toggles (like notifications), trigger the action on tap
            if item.isToggleReadOnly {
                item.action?()
            } else if !item.hasToggle {
                item.action?()
            }
        } label: {
            HStack(spacing: 12) {
                // Icon or flag
                if item.isSystemIcon {
                    Image(systemName: item.icon)
                        .font(.system(size: 18))
                        .foregroundColor(Theme.Colors.text)
                        .frame(width: 24, height: 24)
                } else {
                    // Display the flag or other non-system icon
                    Text(item.icon)
                        .font(.system(size: 20))
                        .frame(width: 24, height: 24)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.text)

                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }

                Spacer()

                if item.hasToggle {
                    if item.isToggleReadOnly {
                        // Read-only toggle: shows current state but not interactive
                        Toggle("", isOn: .constant(item.isToggled))
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: Theme.Colors.primary))
                            .allowsHitTesting(false)
                    } else {
                        // Interactive toggle for dark mode
                        Toggle("", isOn: Binding(
                            get: { isDarkMode },
                            set: { newValue in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isDarkMode = newValue
                                }
                            }
                        ))
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Theme.Colors.primary))
                    }
                }

                // Show chevron when specified (for navigation items or read-only toggles)
                if item.showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MoreTab(isDarkMode: .constant(true), viewModel: .init(), onAuthPresent: {}, onLogoutPresent: {}, onDeleteAccountPresent: {}, onMyProfileClicked: {})
}

// MARK: - WebView
struct WebView: View {
    let pageInfo: PageInfo
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            WebViewContainer(urlString: pageInfo.url)
                .navigationBarTitle(pageInfo.title, displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.Colors.text)
                        .padding(8)
                        .background(Theme.Colors.card)
                        .clipShape(Circle())
                })
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct WebViewContainer: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        // Handle navigation events if needed
    }
}

// MARK: - MailView
struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(["support@iosjumpstart.com"])
        composer.setSubject("iOSJumpstart Support")
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isShowing: $isShowing)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        
        init(isShowing: Binding<Bool>) {
            self._isShowing = isShowing
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            isShowing = false
        }
    }
}

extension View {
    func checkMailAvailability(isShowing: Binding<Bool>) -> some View {
        self.modifier(MailViewModifier(isShowing: isShowing))
    }
}

struct MailViewModifier: ViewModifier {
    @Binding var isShowing: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isShowing) { _, newValue in
                if newValue && !MFMailComposeViewController.canSendMail() {
                    isShowing = false
                    // Show an alert or alternative UI when mail is not available
                    let emailURL = URL(string: "mailto:support@iosjumpstart.com")!
                    if UIApplication.shared.canOpenURL(emailURL) {
                        UIApplication.shared.open(emailURL)
                    }
                }
            }
    }
}
