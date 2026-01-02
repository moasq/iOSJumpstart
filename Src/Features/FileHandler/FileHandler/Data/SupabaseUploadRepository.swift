//
//  SupabaseUploadRepository.swift
//  FileHandler
//

import Foundation
import Supabase

final class SupabaseUploadRepository: UploadRepository, @unchecked Sendable {
    private let storageClient: SupabaseStorageClient

    init(storageClient: SupabaseStorageClient = .shared) {
        self.storageClient = storageClient
    }

    func upload(
        data: Data,
        fileName: String,
        mimeType: MimeType,
        options: UploadOptions
    ) async throws -> UploadResult {
        let finalFileName = options.generateUniqueName
            ? generateUniqueName(for: fileName)
            : fileName

        let path = options.folder.map { "\($0)/\(finalFileName)" } ?? finalFileName

        let fileOptions = FileOptions(
            cacheControl: options.cacheControl,
            contentType: mimeType.rawValue,
            upsert: options.upsert
        )

        do {
            _ = try await storageClient.storage
                .from(options.bucket)
                .upload(path, data: data, options: fileOptions)

            let publicURL = getPublicURL(path: path, bucket: options.bucket)

            return UploadResult(
                path: path,
                publicURL: publicURL,
                size: Int64(data.count),
                mimeType: mimeType.rawValue
            )
        } catch let error as StorageError {
            throw mapStorageError(error, bucket: options.bucket)
        } catch {
            throw FileError.uploadFailed(error)
        }
    }

    func delete(path: String, bucket: String) async throws {
        do {
            _ = try await storageClient.storage
                .from(bucket)
                .remove(paths: [path])
        } catch let error as StorageError {
            throw mapStorageError(error, bucket: bucket)
        } catch {
            throw FileError.unknown(error)
        }
    }

    func getPublicURL(path: String, bucket: String) -> URL? {
        try? storageClient.storage
            .from(bucket)
            .getPublicURL(path: path)
    }

    private func generateUniqueName(for fileName: String) -> String {
        let uuid = UUID().uuidString.prefix(8)
        let ext = (fileName as NSString).pathExtension
        let name = (fileName as NSString).deletingPathExtension
        return "\(name)_\(uuid).\(ext)"
    }

    private func mapStorageError(_ error: StorageError, bucket: String) -> FileError {
        let message = error.message
        let statusCode = error.statusCode

        if message.contains("not found") || message.contains("Bucket not found") {
            return .bucketNotFound(bucket)
        }
        if message.contains("unauthorized") || message.contains("401") || statusCode == "401" {
            return .unauthorized
        }
        return .serverError(message)
    }
}
