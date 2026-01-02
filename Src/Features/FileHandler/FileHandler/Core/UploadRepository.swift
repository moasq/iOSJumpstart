//
//  UploadRepository.swift
//  FileHandler
//

import Foundation

protocol UploadRepository: Sendable {
    func upload(
        data: Data,
        fileName: String,
        mimeType: MimeType,
        options: UploadOptions
    ) async throws -> UploadResult

    func delete(path: String, bucket: String) async throws

    func getPublicURL(path: String, bucket: String) -> URL?
}
