//
//  MoreViewModel.swift
//  iOSJumpstart
//
//

import Foundation
import Factory
import Authentication
import Common
import Combine
import Repositories
import Events
import UIKit
import Subscription

// MARK: - UserDefaults Keys
enum UserDefaultsKeys: String, CaseIterable {
    case isDarkMode = "isDarkMode"

    static func clearAll() {
        allCases.forEach {
            UserDefaults.standard.removeObject(forKey: $0.rawValue)
        }
    }
}

class MoreViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var myProfileInfo: Loadable<ProfileModel?> = .notInitiated
    @Published private(set) var isInitialized = false
    @Published var isAuthenticated = false
    @Published var userEmail: String = ""

    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: UserDefaultsKeys.isDarkMode.rawValue)
        }
    }
    @Published var isNotificationsEnabled: Bool = false
    @Published private(set) var isSubscribed: Bool = false

    // MARK: - Computed Properties
    var isLoading: Bool { myProfileInfo.isLoading }

    // MARK: - Private Properties
    @LazyInjected(\.authStatusRepository) private var authRepository: AuthStatusRepository
    @LazyInjected(\.profileRepository) private var profileRepository: ProfileRepository
    @LazyInjected(\.eventViewModel) private var eventViewModel: EventViewModel
    @LazyInjected(\.notificationService) private var notificationService: NotificationService
    @LazyInjected(\.subscriptionManager) private var subscriptionManager: SubscriptionManager
    private var isRefreshing = false

    // MARK: - Initialization
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDarkMode.rawValue)
    }

    // MARK: - Initialization Method
    @MainActor
    func initialize() {
        guard !isInitialized else { return }

        // Subscribe to profile and subscription events
        eventViewModel.subscribe(for: self, to: [.profile, .subscription]) { [weak self] event in
            guard let self = self else { return }
            if case .profileUpdated = event {
                Task { @MainActor in
                    await self.checkAuthenticationStatus()
                }
            }
            if case .userSubscribed = event {
                Task { @MainActor in
                    self.refreshSubscriptionStatus()
                }
            }
        }

        // Check authentication status
        Task {
            await checkAuthenticationStatus()
        }

        // Check notification status
        Task {
            await checkNotificationStatus()
        }

        // Check subscription status
        refreshSubscriptionStatus()

        isInitialized = true
    }

    deinit {
        eventViewModel.unsubscribe(self)
    }

    // MARK: - Public Methods

    /// Refreshes all data - authentication status and profile
    @MainActor
    func refresh() async {
        isRefreshing = true

        // Check authentication
        await checkAuthenticationStatus()

        isRefreshing = false
    }

    @MainActor
    func checkAuthenticationStatus() async {
        // When refreshing, don't set loading state if we already have profile data
        if !isRefreshing {
            self.myProfileInfo = .loading(existing: myProfileInfo.value)
        }

        isAuthenticated = await authRepository.isAuthenticated()

        if isAuthenticated,
           let user = await authRepository.getCurrentUser() {
            userEmail = user.email

            // Fetch real profile from repository
            do {
                let entity = try await profileRepository.getProfile()
                let profile = ProfileModel(from: entity)
                self.myProfileInfo = .success(profile)
            } catch is CancellationError {
                // Task was cancelled (e.g., view disappeared) - ignore silently
                return
            } catch let error as ProfileError {
                switch error {
                case .profileNotFound:
                    // New user - no profile yet, create placeholder from email
                    let name = user.email.components(separatedBy: "@").first ?? "User"
                    let profile = ProfileModel(fullName: name, avatarURL: nil)
                    self.myProfileInfo = .success(profile)
                case .notAuthenticated:
                    // Auth session not ready yet - show placeholder instead of error
                    let name = user.email.components(separatedBy: "@").first ?? "User"
                    let profile = ProfileModel(fullName: name, avatarURL: nil)
                    self.myProfileInfo = .success(profile)
                default:
                    self.myProfileInfo = .failure(error)
                }
            } catch {
                // Check if it's a cancellation wrapped in another error
                if (error as NSError).code == NSURLErrorCancelled || error.localizedDescription.contains("cancelled") {
                    return
                }
                self.myProfileInfo = .failure(error)
            }
        } else {
            self.myProfileInfo = .notInitiated
            userEmail = ""
        }
    }

    func clearData() {
        UserDefaultsKeys.clearAll()
    }

    @MainActor
    func retry() async {
        await checkAuthenticationStatus()
    }

    // MARK: - Notification Methods

    @MainActor
    func checkNotificationStatus() async {
        let status = await notificationService.getPermissionStatus()
        isNotificationsEnabled = (status == .authorized || status == .provisional)
    }

    func openNotificationSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Subscription Methods

    @MainActor
    func refreshSubscriptionStatus() {
        isSubscribed = subscriptionManager.isSubscribed
    }

    // MARK: - App Rating

    func requestAppRating() {
        eventViewModel.emit(.appRatingRequested)
    }

    func openAppStoreReview() {
        let appStoreID = AppConfiguration.App.appStoreID
        let urlString = "https://apps.apple.com/app/id\(appStoreID)?action=write-review"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Share App

    func shareApp() {
        let appStoreID = AppConfiguration.App.appStoreID
        let appName = AppConfiguration.App.name
        let appStoreURL = URL(string: "https://apps.apple.com/app/id\(appStoreID)")!
        let shareText = "Check out \(appName)!"

        let activityItems: [Any] = [shareText, appStoreURL]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }

        // For iPad support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX, y: rootViewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        rootViewController.present(activityVC, animated: true)
    }
}
