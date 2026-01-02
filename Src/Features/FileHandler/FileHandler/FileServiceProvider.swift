//
//  FileServiceProvider.swift
//  FileHandler
//

import Foundation
import Factory

public protocol FileServiceProvider: Sendable {
    func upload(
        data: Data,
        fileName: String,
        options: UploadOptions,
        compressionConfig: CompressionConfig
    ) async throws -> UploadResult

    func upload(
        data: Data,
        fileName: String
    ) async throws -> UploadResult

    func delete(path: String, bucket: String) async throws
}

public extension FileServiceProvider {
    func upload(data: Data, fileName: String) async throws -> UploadResult {
        try await upload(
            data: data,
            fileName: fileName,
            options: .default,
            compressionConfig: .default
        )
    }
}

// MARK: - Implementation

final class FileServiceProviderImpl: FileServiceProvider {
    @Injected(\.uploadRepository) private var uploadRepository
    @Injected(\.compressionService) private var compressionService

    func upload(
        data: Data,
        fileName: String,
        options: UploadOptions,
        compressionConfig: CompressionConfig
    ) async throws -> UploadResult {
        let fileInfo = FileInfo(data: data, fileName: fileName)

        let finalData: Data
        let finalMimeType: MimeType

        if compressionService.shouldCompress(fileInfo, config: compressionConfig) {
            let result = try await compressionService.compress(fileInfo, config: compressionConfig)
            finalData = result.data
            finalMimeType = .jpeg
        } else {
            finalData = fileInfo.data
            finalMimeType = fileInfo.mimeType
        }

        return try await uploadRepository.upload(
            data: finalData,
            fileName: fileName,
            mimeType: finalMimeType,
            options: options
        )
    }

    func delete(path: String, bucket: String) async throws {
        try await uploadRepository.delete(path: path, bucket: bucket)
    }
}
