//
//  MimeType.swift
//  FileHandler
//

import Foundation

enum MimeType: String, Sendable {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case gif = "image/gif"
    case heic = "image/heic"
    case webp = "image/webp"
    case pdf = "application/pdf"
    case json = "application/json"
    case unknown = "application/octet-stream"

    var isImage: Bool {
        switch self {
        case .jpeg, .png, .gif, .heic, .webp:
            return true
        default:
            return false
        }
    }

    var fileExtension: String {
        switch self {
        case .jpeg: return "jpg"
        case .png: return "png"
        case .gif: return "gif"
        case .heic: return "heic"
        case .webp: return "webp"
        case .pdf: return "pdf"
        case .json: return "json"
        case .unknown: return "bin"
        }
    }

    static func from(extension ext: String) -> MimeType {
        switch ext.lowercased() {
        case "jpg", "jpeg": return .jpeg
        case "png": return .png
        case "gif": return .gif
        case "heic", "heif": return .heic
        case "webp": return .webp
        case "pdf": return .pdf
        case "json": return .json
        default: return .unknown
        }
    }
}
