//
//  SupabaseClient.swift
//  Repositories
//

import Foundation
import Supabase
import Common

final class SupabaseProfileClient: @unchecked Sendable {
    static let shared = SupabaseProfileClient()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: EnvironmentVars.SUPABASE_URL)!,
            supabaseKey: EnvironmentVars.SUPABASE_ANON_KEY
        )
    }

    init(client: SupabaseClient) {
        self.client = client
    }

    var database: PostgrestClient {
        client.database
    }

    var auth: AuthClient {
        client.auth
    }
}

typealias PostgrestClient = Supabase.PostgrestClient
typealias AuthClient = Supabase.AuthClient
