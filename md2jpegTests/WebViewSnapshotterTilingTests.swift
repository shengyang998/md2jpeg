import CoreGraphics
import UIKit
import XCTest
@testable import md2jpeg

final class WebViewSnapshotterTilingTests: XCTestCase {
    func testTileRectsStartAtZeroAndAreContinuous() {
        let snapshotter = WebViewSnapshotter(limits: .default)
        let contentSize = CGSize(width: 800, height: 5200)
        let rects = snapshotter.makeContentTileRects(contentSize: contentSize, viewportHeight: 900)

        XCTAssertFalse(rects.isEmpty)
        XCTAssertEqual(rects.first?.minY ?? -1, 0, accuracy: 0.1)
        XCTAssertEqual(rects.last?.maxY ?? -1, contentSize.height, accuracy: 0.1)

        for index in 1..<rects.count {
            XCTAssertEqual(rects[index - 1].maxY, rects[index].minY, accuracy: 0.1)
        }
    }

    func testCoverageValidationRequiresTopAndBottomCoverage() {
        let snapshotter = WebViewSnapshotter(limits: .default)
        let targetSize = CGSize(width: 1080, height: 3000)
        let image = UIGraphicsImageRenderer(size: CGSize(width: 1080, height: 1000)).image { _ in }

        let fullCoverage = [
            (rect: CGRect(x: 0, y: 0, width: 1080, height: 1000), image: image),
            (rect: CGRect(x: 0, y: 1000, width: 1080, height: 1000), image: image),
            (rect: CGRect(x: 0, y: 2000, width: 1080, height: 1000), image: image)
        ]
        XCTAssertTrue(snapshotter.validateCoverage(capturedTiles: fullCoverage, targetSize: targetSize))

        let missingTop = [
            (rect: CGRect(x: 0, y: 80, width: 1080, height: 1000), image: image),
            (rect: CGRect(x: 0, y: 1080, width: 1080, height: 1920), image: image)
        ]
        XCTAssertFalse(snapshotter.validateCoverage(capturedTiles: missingTop, targetSize: targetSize))

        let missingBottom = [
            (rect: CGRect(x: 0, y: 0, width: 1080, height: 1200), image: image),
            (rect: CGRect(x: 0, y: 1200, width: 1080, height: 1700), image: image)
        ]
        XCTAssertFalse(snapshotter.validateCoverage(capturedTiles: missingBottom, targetSize: targetSize))
    }

    func testEvaluateReadinessRequiresReadyFlagWhenPresent() {
        let snapshotter = WebViewSnapshotter(limits: .default)

        XCTAssertTrue(
            snapshotter.evaluateReadiness(["readyState": "complete", "md2jpegReady": true])
        )
        XCTAssertFalse(
            snapshotter.evaluateReadiness(["readyState": "complete", "md2jpegReady": false])
        )
        XCTAssertFalse(
            snapshotter.evaluateReadiness(["readyState": "interactive", "md2jpegReady": true])
        )
    }

    func testEvaluateReadinessFallsBackForLegacyReadyStateString() {
        let snapshotter = WebViewSnapshotter(limits: .default)
        XCTAssertTrue(snapshotter.evaluateReadiness("complete"))
        XCTAssertFalse(snapshotter.evaluateReadiness("loading"))
    }

    func testEvaluateReadinessAllowsCompleteWhenCustomFlagMissing() {
        let snapshotter = WebViewSnapshotter(limits: .default)

        XCTAssertTrue(snapshotter.evaluateReadiness(["readyState": "complete"]))
        XCTAssertFalse(snapshotter.evaluateReadiness(["readyState": "interactive"]))
    }
}
