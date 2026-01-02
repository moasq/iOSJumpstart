//
//  DeepLinkModifier.swift
//  iOSJumpstart
//
//  Unified deep link setup and handling.
//  Manages coordinator lifecycle, auth state watching, and URL processing.
//

import SwiftUI

// MARK: - Readiness State

/// Tracks the initialization state of the deep linking system.
enum DeepLinkReadiness: Equatable {
    case notReady
    case handlerConfigured
    case fullyReady
}

// MARK: - View Modifier

/// Unified modifier for deep linking setup and URL handling.
struct DeepLinkModifier: ViewModifier {

    // MARK: - Dependencies
    @ObservedObject var navigator: AppNavigator

    // MARK: - State

    @State private var coordinator: DeepLinkCoordinator?
    @State private var handler: DeepLinkHandler?
    @State private var readiness: DeepLinkReadiness = .notReady

    // MARK: - Configuration

    /// Delay after authentication before processing pending deep links.
    /// Ensures the navigation stack is fully initialized and ready.
    private let pendingLinkProcessingDelay: TimeInterval = 0.3

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .onAppear {
                setupCoordinator()
            }
            .onOpenURL { url in
                Task { @MainActor in
                    handler?.handle(url: url)
                }
            }
    }

    // MARK: - Setup

    private func setupCoordinator() {
        #if DEBUG
        print("🔗 DeepLinkModifier: Setting up coordinator...")
        #endif

        // Create handler
        let deepLinkHandler = DeepLinkSetup.createHandler()
        self.handler = deepLinkHandler

        // Create coordinator
        let newCoordinator = DeepLinkCoordinator(
            navigator: navigator
        )

        // Wire them together
        deepLinkHandler.setRouteHandler(newCoordinator)
        self.coordinator = newCoordinator
        self.readiness = .handlerConfigured

        #if DEBUG
        print("🔗 DeepLinkModifier: Setup complete")
        #endif
    }

}

// MARK: - View Extension

extension View {
    /// Set up deep linking for this view.
    /// Should be called once at the root of your app.
    func withDeepLinking(navigator: AppNavigator) -> some View {
        modifier(DeepLinkModifier(navigator: navigator))
    }
}
