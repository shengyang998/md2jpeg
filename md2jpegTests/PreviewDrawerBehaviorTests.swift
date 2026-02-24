import XCTest
@testable import md2jpeg

final class PreviewDrawerBehaviorTests: XCTestCase {
    private let behavior = PreviewDrawerBehavior()

    func testSettlesExpandedWhenVelocityIsStrongUpward() {
        let state = behavior.settledState(currentOffset: 180, hiddenOffset: 300, velocityY: -900)
        XCTAssertEqual(state, .expanded)
    }

    func testSettlesHiddenWhenVelocityIsStrongDownward() {
        let state = behavior.settledState(currentOffset: 20, hiddenOffset: 300, velocityY: 900)
        XCTAssertEqual(state, .hidden)
    }

    func testSettlesExpandedWhenMoreThanHalfOpen() {
        let state = behavior.settledState(currentOffset: 120, hiddenOffset: 300, velocityY: 0)
        XCTAssertEqual(state, .expanded)
    }

    func testSettlesHiddenWhenLessThanHalfOpen() {
        let state = behavior.settledState(currentOffset: 220, hiddenOffset: 300, velocityY: 0)
        XCTAssertEqual(state, .hidden)
    }

    func testExpandedDragActivationUsesTopAreaOnly() {
        XCTAssertTrue(behavior.shouldHandleDrag(startLocationY: 24, currentState: .expanded))
        XCTAssertFalse(behavior.shouldHandleDrag(startLocationY: 140, currentState: .expanded))
    }
}
