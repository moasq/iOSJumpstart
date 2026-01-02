//
//  FileError.swift
//  FileHandler
//

import Foundation

enum FileError: Error, LocalizedError {
    case fileTooLarge(maxSize: Int64, actualSize: Int64)
    case unsupportedFileType(String)
    case compressionFailed(Error)
    case uploadFailed(Error)
    case networkError(Error)
    case invalidData
    case bucketNotFound(String)
    case unauthorized
    case serverError(String)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .fileTooLarge(let maxSize, let actualSize):
            let maxMB = String(format: "%.1f", Double(maxSize) / (1024 * 1024))
            let actualMB = String(format: "%.1f", Double(actualSize) / (1024 * 1024))
            return "File too large: \(actualMB)MB exceeds \(maxMB)MB"
        case .unsupportedFileType(let type):
            return "Unsupported file type: \(type)"
        case .compressionFailed(let error):
            return "Compression failed: \(error.localizedDescription)"
        case .uploadFailed(let error):
            return "Upload failed: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid file data"
        case .bucketNotFound(let bucket):
            return "Bucket not found: \(bucket)"
        case .unauthorized:
            return "Unauthorized"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown(let error):
            return "Error: \(error.localizedDescription)"
        }
    }
}
