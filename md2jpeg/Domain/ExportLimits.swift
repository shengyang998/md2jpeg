import CoreGraphics

struct ExportLimits: Equatable {
    let targetWidth: CGFloat
    let maxPixelCount: CGFloat
    let tileHeight: CGFloat

    static let `default` = ExportLimits(
        targetWidth: 1080,
        maxPixelCount: 40_000_000,
        tileHeight: 2048
    )

    func estimatedPixelCount(contentHeight: CGFloat) -> CGFloat {
        targetWidth * contentHeight
    }

    func isWithinBudget(contentHeight: CGFloat) -> Bool {
        estimatedPixelCount(contentHeight: contentHeight) <= maxPixelCount
    }
}
