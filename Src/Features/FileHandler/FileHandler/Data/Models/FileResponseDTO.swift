//
//  FileResponseDTO.swift
//  FileHandler
//

import Foundation

struct FileResponseDTO: Decodable, Sendable {
    let id: String?
    let path: String
    let fullPath: String?

    func toUploadResult(publicURL: URL?, size: Int64, mimeType: String) -> UploadResult {
        UploadResult(
            path: path,
            publicURL: publicURL,
            size: size,
            mimeType: mimeType
        )
    }
}
