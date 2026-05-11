import CoreGraphics

struct ExportLimits: Equatable {
    /// WebView layout width in points. Controls how content is laid out (column width,
    /// wrapping, font size). For WYSIWYG export this matches the device screen point width.
    let targetWidth: CGFloat
    /// Scale factor applied when snapshotting (points → pixels). Use the device screen
    /// scale (e.g. 3.0) to produce Retina-resolution exports.
    let pixelScale: CGFloat
    let maxPixelCount: CGFloat
    let tileHeight: CGFloat

    static let `default` = ExportLimits(
        targetWidth: 1080,
        pixelScale: 1.0,
        maxPixelCount: 40_000_000,
        tileHeight: 2048
    )

    var targetPixelWidth: CGFloat {
        targetWidth * pixelScale
    }

    func estimatedPixelCount(contentHeight: CGFloat) -> CGFloat {
        targetPixelWidth * (contentHeight * pixelScale)
    }

    func isWithinBudget(contentHeight: CGFloat) -> Bool {
        estimatedPixelCount(contentHeight: contentHeight) <= maxPixelCount
    }
}
