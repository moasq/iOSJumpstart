//
//  FileHandler.swift
//  FileHandler
//

import Foundation

// MARK: - FileHandler Module
//
// A file handling module with compression and Supabase storage upload.
//
// Usage:
// ```swift
// import FileHandler
// import Factory
//
// class ProfileViewModel {
//     @Injected(\.fileServiceProvider) private var fileService
//
//     func uploadProfileImage(_ imageData: Data) async throws -> URL? {
//         let result = try await fileService.upload(
//             data: imageData,
//             fileName: "profile.jpg",
//             options: .avatars(),
//             compressionConfig: .default
//         )
//         return result.publicURL
//     }
// }
// ```
