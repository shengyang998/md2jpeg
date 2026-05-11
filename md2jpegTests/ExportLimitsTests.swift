import XCTest
@testable import md2jpeg

final class ExportLimitsTests: XCTestCase {
    func testWithinBudgetForNormalHeight() {
        let limits = ExportLimits.default
        XCTAssertTrue(limits.isWithinBudget(contentHeight: 5_000))
    }

    func testExceedsBudgetForHugeHeight() {
        let limits = ExportLimits.default
        XCTAssertFalse(limits.isWithinBudget(contentHeight: 100_000))
    }

    func testTargetPixelWidthScalesByPixelScale() {
        let limits = ExportLimits(
            targetWidth: 393,
            pixelScale: 3.0,
            maxPixelCount: 40_000_000,
            tileHeight: 2048
        )
        XCTAssertEqual(limits.targetPixelWidth, 1179, accuracy: 0.01)
    }

    func testBudgetAccountsForPixelScale() {
        // 393pt × 3.0 = 1179px wide. A 10_000pt-tall document expands to 30_000px tall
        // in the output, so the pixel budget must factor in pixelScale.
        let limits = ExportLimits(
            targetWidth: 393,
            pixelScale: 3.0,
            maxPixelCount: 40_000_000,
            tileHeight: 2048
        )
        XCTAssertTrue(limits.isWithinBudget(contentHeight: 10_000))
        XCTAssertFalse(limits.isWithinBudget(contentHeight: 12_000))
    }
}
