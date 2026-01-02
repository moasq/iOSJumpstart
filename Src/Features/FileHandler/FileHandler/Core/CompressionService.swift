//
//  CompressionService.swift
//  FileHandler
//

import Foundation

protocol CompressionService: Sendable {
    func compress(
        _ fileInfo: FileInfo,
        config: CompressionConfig
    ) async throws -> CompressionResult

    func shouldCompress(_ fileInfo: FileInfo, config: CompressionConfig) -> Bool
}
