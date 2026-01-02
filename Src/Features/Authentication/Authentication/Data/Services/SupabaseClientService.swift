//
//  SupabaseClientService.swift
//  Authentication
//
//  Supabase client singleton for authentication operations.
//

import Foundation
import Supabase
import Common

final class SupabaseClientService: @unchecked Sendable {
    static let shared = SupabaseClientService()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: EnvironmentVars.SUPABASE_URL)!,
            supabaseKey: EnvironmentVars.SUPABASE_ANON_KEY
        )
    }

    /// For testing purposes
    init(client: SupabaseClient) {
        self.client = client
    }
}
