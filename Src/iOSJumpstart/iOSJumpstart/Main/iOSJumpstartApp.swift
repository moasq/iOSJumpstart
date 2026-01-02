//
//  iOSJumpstartApp.swift
//  iOSJumpstart
//
//

import SwiftUI
import FirebaseAnalytics

@main
struct iOSJumpstartApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isDarkMode") private var isDarkMode = false

    init() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
