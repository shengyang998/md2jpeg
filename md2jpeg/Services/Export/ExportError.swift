import Foundation

enum ExportError: LocalizedError {
    case missingWebView
    case previewStillRendering
    case unableToMeasureContent
    case unstableContentLayout
    case contentExceedsLimit
    case incompleteTileCapture
    case incompleteComposedImage
    case snapshotFailed
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .missingWebView:
            return "Preview is not ready yet. Please wait and try again."
        case .previewStillRendering:
            return "Preview is still rendering. Please wait a moment and try export again."
        case .unableToMeasureContent:
            return "Unable to measure rendered content for export."
        case .unstableContentLayout:
            return "Content layout is still changing. Please wait and try export again."
        case .contentExceedsLimit:
            return "Content is too long for safe single-image export. Try shortening the markdown."
        case .incompleteTileCapture:
            return "Export capture was incomplete. Please retry after preview settles."
        case .incompleteComposedImage:
            return "Export image was incomplete. Please retry export."
        case .snapshotFailed:
            return "Failed to capture preview image."
        case .encodingFailed:
            return "Failed to encode image in the selected format."
        }
    }
}
