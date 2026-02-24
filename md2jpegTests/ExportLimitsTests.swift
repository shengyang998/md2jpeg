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
}
