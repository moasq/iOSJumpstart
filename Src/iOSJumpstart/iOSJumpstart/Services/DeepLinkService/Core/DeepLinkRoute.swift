//
//  DeepLinkRoute.swift
//  iOSJumpstart
//
//  Generic deep link route structure.
//  Supports any path with dynamic parameters.
//

import Foundation

// MARK: - DeepLink Route

/// A generic deep link route that can represent any path with parameters.
/// This replaces the enum-based approach for more flexibility.
///
/// Example URLs:
/// - `iosjumpstart://profile` → DeepLinkRoute(path: "profile")
/// - `iosjumpstart://product/123` → DeepLinkRoute(path: "product/123")
/// - `iosjumpstart://promo?code=SUMMER` → DeepLinkRoute(path: "promo", parameters: ["code": "SUMMER"])
/// - `https://iosjumpstart.app/article/456` → DeepLinkRoute(path: "article/456")
///
struct DeepLinkRoute: Equatable, Sendable {
    /// The path component (e.g., "profile", "product/123", "settings")
    let path: String

    /// Query parameters from the URL
    let parameters: [String: String]

    /// URL fragment (the part after #)
    let fragment: String?

    /// The original URL that created this route
    let originalURL: URL?

    init(
        path: String,
        parameters: [String: String] = [:],
        fragment: String? = nil,
        originalURL: URL? = nil
    ) {
        self.path = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.parameters = parameters
        self.fragment = fragment
        self.originalURL = originalURL
    }

    // MARK: - Convenience Accessors

    /// Get the first component of the path (e.g., "product" from "product/123")
    var firstPathComponent: String? {
        path.components(separatedBy: "/").first
    }

    /// Get all path components as array
    var pathComponents: [String] {
        path.components(separatedBy: "/").filter { !$0.isEmpty }
    }

    /// Get a specific path component by index
    func pathComponent(at index: Int) -> String? {
        let components = pathComponents
        guard index >= 0 && index < components.count else { return nil }
        return components[index]
    }

    /// Get a parameter value by key
    subscript(key: String) -> String? {
        parameters[key]
    }
}

// MARK: - Common Route Helpers

extension DeepLinkRoute {
    /// Check if this route matches a specific path pattern
    /// Examples:
    /// - route.matches("profile") → true if path is "profile"
    /// - route.matches("product/*") → true if path starts with "product/"
    func matches(_ pattern: String) -> Bool {
        if pattern.hasSuffix("/*") {
            let prefix = String(pattern.dropLast(2))
            return path.hasPrefix(prefix)
        }
        return path == pattern
    }

    /// Common route predicates
    var isHome: Bool { path.isEmpty || path == "home" }
    var isProfile: Bool { matches("profile") }
    var isSettings: Bool { matches("settings") }
    var isAuth: Bool { matches("login") || matches("signup") || matches("reset-password") }
}

// MARK: - URL Generation

extension DeepLinkRoute {
    /// Generate a URL from this route
    func toURL(scheme: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme

        if path.isEmpty {
            components.host = "home"
        } else if let firstComponent = firstPathComponent {
            components.host = firstComponent
            let remainingPath = pathComponents.dropFirst().joined(separator: "/")
            if !remainingPath.isEmpty {
                components.path = "/\(remainingPath)"
            }
        }

        if !parameters.isEmpty {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        components.fragment = fragment

        return components.url
    }

    /// Generate a Universal Link from this route
    func toUniversalLink(domain: String, https: Bool = true) -> URL? {
        var components = URLComponents()
        components.scheme = https ? "https" : "http"
        components.host = domain

        if !path.isEmpty {
            components.path = "/\(path)"
        }

        if !parameters.isEmpty {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        components.fragment = fragment

        return components.url
    }
}
