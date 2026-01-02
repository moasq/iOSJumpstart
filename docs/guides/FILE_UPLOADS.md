# File Uploads

**Pattern**: FileHandler → Compression → Supabase Storage

## Quick Upload

```swift
@LazyInjected(\.fileServiceProvider) private var fileService

let result = try await fileService.upload(
    data: imageData,
    fileName: "\(UUID().uuidString).jpg",
    mimeType: .jpeg,
    options: .avatars()
)

print("Public URL: \(result.publicURL)")
```

## Upload Options

```swift
UploadOptions(
    bucket: "storage",          // Supabase bucket name
    folder: "avatars",          // Optional folder
    isPublic: true,            // Public or private
    compressionConfig: .default // Auto-compression
)

// Presets
.avatars()      // Public avatars
.privateFiles() // Private files
.custom(...)    // Custom config
```

## Complete Example

```swift
import PhotosUI

struct ProfileImagePicker: View {
    @LazyInjected(\.fileServiceProvider) private var fileService
    @State private var selectedItem: PhotosPickerItem?
    @State private var isUploading = false

    var body: some View {
        PhotosPicker(selection: $selectedItem) {
            Image(systemName: "person.circle")
        }
        .onChange(of: selectedItem) { newItem in
            uploadImage(newItem)
        }
    }

    private func uploadImage(_ item: PhotosPickerItem?) {
        guard let item else { return }
        isUploading = true

        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let result = try await fileService.upload(
                    data: data,
                    fileName: "\(UUID().uuidString).jpg",
                    mimeType: .jpeg,
                    options: .avatars()
                )
                print("Uploaded: \(result.publicURL)")
            }
            isUploading = false
        }
    }
}
```

## Compression

Automatic compression enabled by default:

```swift
CompressionConfig(
    quality: 0.8,              // 80% quality
    maxDimension: 1200,        // Max width/height
    shouldCompress: true
)
```

**Reference**: `Src/Features/FileHandler/FileHandler/FileHandler.swift`

**Usage example**: `Src/iOSJumpstart/iOSJumpstart/App/Tabs/More/View/Profile/MyProfileView.swift:120-180`
