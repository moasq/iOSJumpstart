//
//  UploadOptions.swift
//  FileHandler
//

import Foundation

public struct UploadOptions: Sendable {
    public let bucket: String
    public let folder: String?
    public let cacheControl: String
    public let upsert: Bool
    public let generateUniqueName: Bool

    public init(
        bucket: String,
        folder: String? = nil,
        cacheControl: String = "3600",
        upsert: Bool = false,
        generateUniqueName: Bool = true
    ) {
        self.bucket = bucket
        self.folder = folder
        self.cacheControl = cacheControl
        self.upsert = upsert
        self.generateUniqueName = generateUniqueName
    }

    public static let `default` = UploadOptions(bucket: "storage")

    public static func avatars(upsert: Bool = true) -> UploadOptions {
        UploadOptions(
            bucket: "storage",
            folder: "avatars",
            cacheControl: "86400",
            upsert: upsert
        )
    }
}
