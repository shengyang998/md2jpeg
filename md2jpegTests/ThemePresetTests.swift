import XCTest
@testable import md2jpeg

final class ThemePresetTests: XCTestCase {
    func testAtLeastThreeBundledThemesExist() {
        XCTAssertGreaterThanOrEqual(ThemePreset.allCases.count, 3)
    }

    func testThemeDisplayNamesAreStable() {
        XCTAssertEqual(ThemePreset.classic.displayName, "Classic")
        XCTAssertEqual(ThemePreset.paper.displayName, "Paper")
        XCTAssertEqual(ThemePreset.dark.displayName, "Dark")
    }
}
