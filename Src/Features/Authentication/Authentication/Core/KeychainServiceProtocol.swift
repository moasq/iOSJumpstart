//
//  KeychainServiceProtocol.swift
//  Authentication
//
//


// KeychainServiceProtocol.swift
// Common module

import Foundation

public protocol KeychainServiceProtocol {
    func save(key: String, data: Data) throws
    func retrieve(key: String) throws -> Data
    func delete(key: String) throws
}

public enum KeychainError: Error {
    case saveError(OSStatus)
    case retrieveError(OSStatus)
    case deleteError(OSStatus)
    case unexpectedData
}

public class KeychainService: KeychainServiceProtocol {
    public init() {}
    
    public func save(key: String, data: Data) throws {
        // Query to check if item exists
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.mosal.Authentication"
        ]
        
        // Delete existing item if it exists
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let saveQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.mosal.Authentication",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(saveQuery as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw KeychainError.saveError(status)
        }
    }
    
    public func retrieve(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.mosal.Authentication",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            throw KeychainError.retrieveError(status)
        }
        
        guard let data = item as? Data else {
            throw KeychainError.unexpectedData
        }
        
        return data
    }
    
    public func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.mosal.Authentication"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        // Consider not found as success for deletion
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.deleteError(status)
        }
    }
}