import CoreGraphics
import XCTest
@testable import md2jpeg

final class LongDocumentSafetyTests: XCTestCase {
    func testStressHeightsAreRejectedBeforeRender() {
        let limits = ExportLimits.default
        let stressHeights: [CGFloat] = [120_000, 250_000, 500_000]

        for height in stressHeights {
            XCTAssertFalse(
                limits.isWithinBudget(contentHeight: height),
                "Expected height \(height) to exceed memory budget"
            )
        }
    }
}
