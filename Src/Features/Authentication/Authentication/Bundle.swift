//
//  Bundle.swift
//  Authentication
//
//

import Foundation
import SwiftUI

extension Bundle {
    // This will get the bundle for the Authentication module
    static var authenticationBundle: Bundle {
        // Try to find the bundle using the explicit identifier
        if let bundle = Bundle(identifier: "com.mosal.Authentication") {
            return bundle
        }
        
        // Fallback options if the identifier doesn't work
        let candidates = [
            // Bundle containing a known class from your module
            Bundle(for: AuthenticationViewModel.self),
            // Main bundle as last resort
            Bundle.main
        ]
        
        for candidate in candidates {
            if let bundleURL = candidate.resourceURL?.appendingPathComponent("Authentication.bundle"),
               let bundle = Bundle(url: bundleURL) {
                return bundle
            }
        }
        
        // Final fallback to the bundle containing the class
        return Bundle(for: AuthenticationViewModel.self)
    }
}
