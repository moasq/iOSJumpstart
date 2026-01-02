//
//  DeepLinkSetup.swift
//  iOSJumpstart
//
//  Simple factory for creating deep link components.
//

import Foundation
import Common

// MARK: - Configuration

/// Deep link configuration
struct DeepLinkConfig: Sendable {
    let urlScheme: String
    let universalLinkDomains: [String]

    init(urlScheme: String, universalLinkDomains: [String] = []) {
        self.urlScheme = urlScheme
        self.universalLinkDomains = universalLinkDomains
    }
}

// MARK: - Setup

enum DeepLinkSetup {
    /// Create a configured deep link handler
    static func createHandler() -> DeepLinkHandler {
        let config = DeepLinkConfig(
            urlScheme: AppConfiguration.DeepLink.urlScheme,
            universalLinkDomains: AppConfiguration.DeepLink.universalLinkDomains
        )

        let parser = DeepLinkParser(
            urlScheme: config.urlScheme,
            universalLinkDomains: config.universalLinkDomains
        )

        return DeepLinkHandler(parser: parser)
    }
}
