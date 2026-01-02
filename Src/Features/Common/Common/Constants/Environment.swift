//
//  Environment.swift
//  iOSJumpstart
//
//
//  This file provides backward compatibility with existing code.
//  All configuration values are now managed in AppConfiguration.swift
//

import Foundation

public enum EnvironmentVars {
    public static var API_BASE_URL: String { AppConfiguration.API.baseURL }
    public static var SUPABASE_URL: String { AppConfiguration.Supabase.url }
    public static var SUPABASE_ANON_KEY: String { AppConfiguration.Supabase.anonKey }
    public static var GOOGLE_CLIENT_ID: String { AppConfiguration.Google.clientID }
}
