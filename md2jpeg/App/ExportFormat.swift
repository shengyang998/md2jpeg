import Foundation
import UniformTypeIdentifiers

enum ExportFormat: String, CaseIterable, Identifiable {
    case png
    case jpeg
    case heic

    var id: String { rawValue }

    var displayName: String {
        rawValue.uppercased()
    }

    var fileExtension: String {
        switch self {
        case .png:
            return "png"
        case .jpeg:
            return "jpg"
        case .heic:
            return "heic"
        }
    }

    var utType: UTType {
        switch self {
        case .png:
            return .png
        case .jpeg:
            return .jpeg
        case .heic:
            return .heic
        }
    }
}
