//
//  DeepLinkCoordinator.swift
//  iOSJumpstart
//
//  Coordinates deep link routing with app navigation.
//  Maps DeepLinkRoute → AppRoute.
//

import Foundation

@MainActor
final class DeepLinkCoordinator: DeepLinkRouting {

    // MARK: - Dependencies

    private weak var navigator: AppNavigator?

    // MARK: - Initialization

    init(navigator: AppNavigator) {
        self.navigator = navigator
    }

    // MARK: - DeepLinkRouting

    func route(to route: DeepLinkRoute) -> Bool {
        guard let navigator else {
            #if DEBUG
            print("🔗 DeepLinkCoordinator: Navigator not available")
            #endif
            return false
        }

        // Map deep link route to app route
        guard let appRoute = mapToAppRoute(route) else {
            #if DEBUG
            print("🔗 DeepLinkCoordinator: Unknown route: \(route.path)")
            #endif
            return false
        }

        #if DEBUG
        print("🔗 DeepLinkCoordinator: Mapped \(route.path) → \(appRoute)")
        #endif

        // Perform navigation
        performNavigation(to: appRoute, with: navigator)
        return true
    }

    // MARK: - Route Mapping

    private func mapToAppRoute(_ route: DeepLinkRoute) -> AppRoute? {
        let path = route.path.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        switch path {
        case "profile":
            return .myProfile(userId: route.parameters["userId"])
        case "settings":
            return .settings(section: route.parameters["section"])
        case "showcase":
            return .showcase
        case "more":
            return .more
        default:
            return nil
        }
    }

    // MARK: - Navigation

    private func performNavigation(to route: AppRoute, with navigator: AppNavigator) {
        switch route {
        case .showcase:
            navigator.navigateToTab(0)
        case .more:
            navigator.navigateToTab(1)
        case .myProfile, .settings:
            navigator.navigate(to: route)
        }
    }
}
