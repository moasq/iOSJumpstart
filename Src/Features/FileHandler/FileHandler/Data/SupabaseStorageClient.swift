//
//  SupabaseStorageClient.swift
//  FileHandler
//

import Foundation
import Supabase
import Common

final class SupabaseStorageClient: @unchecked Sendable {
    static let shared = SupabaseStorageClient()

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

    var storage: SupabaseStorageClient_Storage {
        client.storage
    }
}

typealias SupabaseStorageClient_Storage = Supabase.SupabaseStorageClient
