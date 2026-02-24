import Foundation
import Photos

enum PhotoLibrarySaveError: LocalizedError {
    case permissionDenied
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Photo access is required to save exports. Please allow Photos access in Settings."
        case .saveFailed:
            return "Failed to save image to Photos."
        }
    }
}

struct PhotoLibrarySaver {
    func saveImage(at fileURL: URL) async throws {
        let status = await requestAddOnlyAuthorizationIfNeeded()
        guard status == .authorized || status == .limited else {
            throw PhotoLibrarySaveError.permissionDenied
        }

        try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, fileURL: fileURL, options: nil)
            }, completionHandler: { success, _ in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: PhotoLibrarySaveError.saveFailed)
                }
            })
        }
    }

    private func requestAddOnlyAuthorizationIfNeeded() async -> PHAuthorizationStatus {
        let current = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if current != .notDetermined {
            return current
        }
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
    }
}
