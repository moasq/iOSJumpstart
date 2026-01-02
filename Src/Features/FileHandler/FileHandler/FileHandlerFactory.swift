//
//  FileHandlerFactory.swift
//  FileHandler
//
//

import Foundation
import Factory

// MARK: - Internal Dependencies

extension Container {
    var uploadRepository: Factory<UploadRepository> {
        self { SupabaseUploadRepository() }
    }

    var compressionService: Factory<CompressionService> {
        self { ImageCompressionService() }
    }
}

// MARK: - Public Dependencies

public extension Container {
    var fileServiceProvider: Factory<FileServiceProvider> {
        self { FileServiceProviderImpl() }
    }
}
