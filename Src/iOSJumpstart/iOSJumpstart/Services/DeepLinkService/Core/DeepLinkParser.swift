//
//  DeepLinkParser.swift
//  iOSJumpstart
//
//  Parses URLs into DeepLinkRoute structures.
//  Supports both URL schemes (iosjumpstart://) and Universal Links (https://).
//

import Foundation

// MARK: - Parser Protocol

protocol DeepLinkParsing: Sendable {
    func parse(url: URL) -> DeepLinkRoute?
    func parse(userActivity: NSUserActivity) -> DeepLinkRoute?
}

// MARK: - Parser Implementation

final class DeepLinkParser: DeepLinkParsing, Sendable {
    /// Your app's URL scheme (e.g., "iosjumpstart")
    private let urlScheme: String

    /// Your Universal Link domains (e.g., ["iosjumpstart.app", "www.iosjumpstart.app"])
    private let universalLinkDomains: [String]

    init(
        urlScheme: String,
        universalLinkDomains: [String] = []
    ) {
        self.urlScheme = urlScheme
        self.universalLinkDomains = universalLinkDomains
    }

    // MARK: - Public API

    /// Parse a URL into a DeepLinkRoute
    func parse(url: URL) -> DeepLinkRoute? {
        // Check if it's our URL scheme
        if url.scheme == urlScheme {
            return parseSchemeURL(url)
        }

        // Check if it's a Universal Link
        if let host = url.host, universalLinkDomains.contains(host) {
            return parseUniversalLink(url)
        }

        // Check for https scheme with our domains
        if url.scheme == "https" || url.scheme == "http" {
            if let host = url.host, universalLinkDomains.contains(host) {
                return parseUniversalLink(url)
            }
        }

        return nil
    }

    /// Parse an NSUserActivity (for Universal Links from Handoff)
    func parse(userActivity: NSUserActivity) -> DeepLinkRoute? {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return nil
        }
        return parse(url: url)
    }

    // MARK: - Private Parsing

    /// Parse URL scheme links: iosjumpstart://path/param?key=value
    private func parseSchemeURL(_ url: URL) -> DeepLinkRoute? {
        // For scheme URLs: iosjumpstart://host/path
        var pathString = ""

        if let host = url.host, !host.isEmpty {
            pathString = host
        }

        let pathComponents = url.pathComponents.filter { $0 != "/" }
        if !pathComponents.isEmpty {
            pathString += "/" + pathComponents.joined(separator: "/")
        }

        let parameters = queryItems(from: url)
        let fragment = url.fragment

        return DeepLinkRoute(
            path: pathString,
            parameters: parameters,
            fragment: fragment,
            originalURL: url
        )
    }

    /// Parse Universal Links: https://iosjumpstart.app/path/param?key=value
    private func parseUniversalLink(_ url: URL) -> DeepLinkRoute? {
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        let pathString = pathComponents.joined(separator: "/")
        let parameters = queryItems(from: url)
        let fragment = url.fragment

        return DeepLinkRoute(
            path: pathString,
            parameters: parameters,
            fragment: fragment,
            originalURL: url
        )
    }

    /// Extract query items from URL
    private func queryItems(from url: URL) -> [String: String] {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: items.compactMap { item in
            guard let value = item.value else { return nil }
            return (item.name, value)
        })
    }
}
