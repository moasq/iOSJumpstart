//
//  FileEntity.swift
//  FileHandler
//

import Foundation

public struct UploadResult: Sendable {
    public let path: String
    public let publicURL: URL?
    public let size: Int64
    public let mimeType: String
}

struct FileInfo: Sendable {
    let data: Data
    let fileName: String
    let mimeType: MimeType

    var originalSize: Int64 {
        Int64(data.count)
    }

    var isImage: Bool {
        mimeType.isImage
    }

    init(data: Data, fileName: String, mimeType: MimeType) {
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }

    init(data: Data, fileName: String) {
        self.data = data
        self.fileName = fileName
        let ext = (fileName as NSString).pathExtension
        self.mimeType = MimeType.from(extension: ext)
    }
}

struct CompressionResult: Sendable {
    let data: Data
    let originalSize: Int64
    let compressedSize: Int64
    let wasCompressed: Bool

    var compressionRatio: Double {
        guard originalSize > 0 else { return 0 }
        return Double(originalSize - compressedSize) / Double(originalSize)
    }
}
