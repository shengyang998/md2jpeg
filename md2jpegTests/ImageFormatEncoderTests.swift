import XCTest
@testable import md2jpeg

final class ImageFormatEncoderTests: XCTestCase {
    func testHEICFallsBackToJPEGWhenUnavailable() {
        let encoder = ImageFormatEncoder()
        let resolved = encoder.resolveFormat(preferredFormat: .heic, heicSupported: false)
        XCTAssertEqual(resolved, .jpeg)
    }

    func testHEICStaysHEICWhenAvailable() {
        let encoder = ImageFormatEncoder()
        let resolved = encoder.resolveFormat(preferredFormat: .heic, heicSupported: true)
        XCTAssertEqual(resolved, .heic)
    }
}
