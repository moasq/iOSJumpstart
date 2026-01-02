//
//  Networking.swift
//  Networking.Data
//
//

import Foundation

// Protocol defining networking behavior
public protocol NetworkingProtocol {
    func post<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T,
        headers: [String: String]?,
        token: String?
    ) async throws -> U
    
    // No-response variant for operations that don't return data
    func post<T: Encodable>(
        endpoint: String,
        body: T,
        headers: [String: String]?,
        token: String?
    ) async throws
    
    func get<T: Decodable>(
        endpoint: String,
        queryParams: [String: String],
        headers: [String: String]?,
        token: String?
    ) async throws -> T
    
    func delete<T: Decodable>(
        endpoint: String,
        queryParams: [String: String],
        headers: [String: String]?,
        token: String?
    ) async throws -> T
    
    // No-response variant for operations that don't return data
    func delete(
        endpoint: String,
        queryParams: [String: String],
        headers: [String: String]?,
        token: String?
    ) async throws
    
    func patch<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T,
        headers: [String: String]?,
        token: String?
    ) async throws -> U
    
    // No-response variant for patch operations
    func patch<T: Encodable>(
        endpoint: String,
        body: T,
        headers: [String: String]?,
        token: String?
    ) async throws
}

// Default parameters extension for backward compatibility
public extension NetworkingProtocol {
    func post<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T
    ) async throws -> U {
        try await post(endpoint: endpoint, body: body, headers: nil, token: nil)
    }
    
    func post<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T,
        headers: [String: String]?
    ) async throws -> U {
        try await post(endpoint: endpoint, body: body, headers: headers, token: nil)
    }
    
    func post<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T,
        token: String?
    ) async throws -> U {
        try await post(endpoint: endpoint, body: body, headers: nil, token: token)
    }
    
    func post<T: Encodable>(
        endpoint: String,
        body: T
    ) async throws {
        try await post(endpoint: endpoint, body: body, headers: nil, token: nil)
    }
    
    func post<T: Encodable>(
        endpoint: String,
        body: T,
        headers: [String: String]?
    ) async throws {
        try await post(endpoint: endpoint, body: body, headers: headers, token: nil)
    }
    
    func post<T: Encodable>(
        endpoint: String,
        body: T,
        token: String?
    ) async throws {
        try await post(endpoint: endpoint, body: body, headers: nil, token: token)
    }
    
    func get<T: Decodable>(
        endpoint: String,
        queryParams: [String: String] = [:]
    ) async throws -> T {
        try await get(endpoint: endpoint, queryParams: queryParams, headers: nil, token: nil)
    }
    
    func get<T: Decodable>(
        endpoint: String,
        queryParams: [String: String] = [:],
        headers: [String: String]?
    ) async throws -> T {
        try await get(endpoint: endpoint, queryParams: queryParams, headers: headers, token: nil)
    }
    
    func get<T: Decodable>(
        endpoint: String,
        queryParams: [String: String] = [:],
        token: String?
    ) async throws -> T {
        try await get(endpoint: endpoint, queryParams: queryParams, headers: nil, token: token)
    }
    
    func delete<T: Decodable>(
        endpoint: String,
        queryParams: [String: String] = [:]
    ) async throws -> T {
        try await delete(endpoint: endpoint, queryParams: queryParams, headers: nil, token: nil)
    }
    
    func delete<T: Decodable>(
        endpoint: String,
        queryParams: [String: String] = [:],
        headers: [String: String]?
    ) async throws -> T {
        try await delete(endpoint: endpoint, queryParams: queryParams, headers: headers, token: nil)
    }
    
    func delete<T: Decodable>(
        endpoint: String,
        queryParams: [String: String] = [:],
        token: String?
    ) async throws -> T {
        try await delete(endpoint: endpoint, queryParams: queryParams, headers: nil, token: token)
    }
    
    func delete(
        endpoint: String,
        queryParams: [String: String] = [:]
    ) async throws {
        try await delete(endpoint: endpoint, queryParams: queryParams, headers: nil, token: nil)
    }
    
    func delete(
        endpoint: String,
        queryParams: [String: String] = [:],
        headers: [String: String]?
    ) async throws {
        try await delete(endpoint: endpoint, queryParams: queryParams, headers: headers, token: nil)
    }
    
    func delete(
        endpoint: String,
        queryParams: [String: String] = [:],
        token: String?
    ) async throws {
        try await delete(endpoint: endpoint, queryParams: queryParams, headers: nil, token: token)
    }
    
    func patch<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T
    ) async throws -> U {
        try await patch(endpoint: endpoint, body: body, headers: nil, token: nil)
    }
    
    func patch<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T,
        headers: [String: String]?
    ) async throws -> U {
        try await patch(endpoint: endpoint, body: body, headers: headers, token: nil)
    }
    
    func patch<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T,
        token: String?
    ) async throws -> U {
        try await patch(endpoint: endpoint, body: body, headers: nil, token: token)
    }
    
    func patch<T: Encodable>(
        endpoint: String,
        body: T
    ) async throws {
        try await patch(endpoint: endpoint, body: body, headers: nil, token: nil)
    }
    
    func patch<T: Encodable>(
        endpoint: String,
        body: T,
        headers: [String: String]?
    ) async throws {
        try await patch(endpoint: endpoint, body: body, headers: headers, token: nil)
    }
    
    func patch<T: Encodable>(
        endpoint: String,
        body: T,
        token: String?
    ) async throws {
        try await patch(endpoint: endpoint, body: body, headers: nil, token: token)
    }
}
