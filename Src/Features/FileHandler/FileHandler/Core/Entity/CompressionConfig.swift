//
//  CompressionConfig.swift
//  FileHandler
//

import Foundation

public struct CompressionConfig: Sendable {
    public let maxFileSizeBytes: Int64
    public let targetQuality: CGFloat
    public let maxDimension: CGFloat?

    public init(
        maxFileSizeBytes: Int64,
        targetQuality: CGFloat,
        maxDimension: CGFloat?
    ) {
        self.maxFileSizeBytes = maxFileSizeBytes
        self.targetQuality = targetQuality
        self.maxDimension = maxDimension
    }

    public static let `default` = CompressionConfig(
        maxFileSizeBytes: 5 * 1024 * 1024,
        targetQuality: 0.8,
        maxDimension: 2048
    )

    public static let highQuality = CompressionConfig(
        maxFileSizeBytes: 10 * 1024 * 1024,
        targetQuality: 0.9,
        maxDimension: 4096
    )

    public static let lowBandwidth = CompressionConfig(
        maxFileSizeBytes: 1 * 1024 * 1024,
        targetQuality: 0.6,
        maxDimension: 1024
    )

    public static let noCompression = CompressionConfig(
        maxFileSizeBytes: Int64.max,
        targetQuality: 1.0,
        maxDimension: nil
    )
}
