//
//  ImageCompressionService.swift
//  FileHandler
//

import Foundation
import UIKit

final class ImageCompressionService: CompressionService, Sendable {
    func compress(
        _ fileInfo: FileInfo,
        config: CompressionConfig
    ) async throws -> CompressionResult {
        guard fileInfo.isImage else {
            return CompressionResult(
                data: fileInfo.data,
                originalSize: fileInfo.originalSize,
                compressedSize: fileInfo.originalSize,
                wasCompressed: false
            )
        }

        guard let image = UIImage(data: fileInfo.data) else {
            throw FileError.invalidData
        }

        let resizedImage = resizeIfNeeded(image, maxDimension: config.maxDimension)
        var quality = config.targetQuality
        var compressedData = resizedImage.jpegData(compressionQuality: quality)

        while let data = compressedData,
              Int64(data.count) > config.maxFileSizeBytes,
              quality > 0.1 {
            quality -= 0.1
            compressedData = resizedImage.jpegData(compressionQuality: quality)
        }

        guard let finalData = compressedData else {
            throw FileError.compressionFailed(
                NSError(domain: "ImageCompressionService", code: -1)
            )
        }

        return CompressionResult(
            data: finalData,
            originalSize: fileInfo.originalSize,
            compressedSize: Int64(finalData.count),
            wasCompressed: true
        )
    }

    func shouldCompress(_ fileInfo: FileInfo, config: CompressionConfig) -> Bool {
        fileInfo.isImage && fileInfo.originalSize > config.maxFileSizeBytes
    }

    private func resizeIfNeeded(_ image: UIImage, maxDimension: CGFloat?) -> UIImage {
        guard let maxDim = maxDimension else { return image }

        let size = image.size
        let maxSide = max(size.width, size.height)

        guard maxSide > maxDim else { return image }

        let scale = maxDim / maxSide
        let newSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
