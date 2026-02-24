import ImageIO
import UIKit
import UniformTypeIdentifiers

struct ImageFormatEncoder {
    func encode(
        image: UIImage,
        preferredFormat: ExportFormat,
        outputURL: URL
    ) throws -> (fileURL: URL, usedFormat: ExportFormat) {
        let actualFormat = resolveFormat(preferredFormat: preferredFormat, heicSupported: supportsHEIC())

        guard let cgImage = image.cgImage else {
            throw ExportError.encodingFailed
        }

        guard let destination = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            actualFormat.utType.identifier as CFString,
            1,
            nil
        ) else {
            throw ExportError.encodingFailed
        }

        let properties: CFDictionary
        switch actualFormat {
        case .jpeg:
            properties = [kCGImageDestinationLossyCompressionQuality: 0.92] as CFDictionary
        case .heic:
            properties = [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary
        case .png:
            properties = [:] as CFDictionary
        }

        CGImageDestinationAddImage(destination, cgImage, properties)
        guard CGImageDestinationFinalize(destination) else {
            throw ExportError.encodingFailed
        }

        return (outputURL, actualFormat)
    }

    func supportsHEIC() -> Bool {
        let identifiers = CGImageDestinationCopyTypeIdentifiers() as? [String] ?? []
        return identifiers.contains(UTType.heic.identifier)
    }

    func resolveFormat(preferredFormat: ExportFormat, heicSupported: Bool) -> ExportFormat {
        if preferredFormat == .heic && !heicSupported {
            return .jpeg
        }
        return preferredFormat
    }
}
