//
//  AppleAuthProvider.swift
//  Authentication
//
//


import Foundation

protocol AppleAuthProvider {
    func authenticate() async throws -> AuthModel.AppleAuthResult
}

protocol GoogleAuthProvider {
    func authenticate() async throws -> AuthModel.GoogleAuthResult
}
