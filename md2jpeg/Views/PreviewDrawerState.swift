import CoreGraphics

enum PreviewDrawerState: Equatable {
    case hidden
    case dragging
    case expanded
}

struct PreviewDrawerBehavior {
    let velocityThreshold: CGFloat = 700
    let topPullDownCollapseDistance: CGFloat = 56
    let expandedDragActivationHeight: CGFloat = 88

    func clampedOffset(_ offset: CGFloat, hiddenOffset: CGFloat) -> CGFloat {
        min(max(offset, 0), hiddenOffset)
    }

    func shouldHandleDrag(startLocationY: CGFloat, currentState: PreviewDrawerState) -> Bool {
        currentState != .expanded || startLocationY <= expandedDragActivationHeight
    }

    func settledState(currentOffset: CGFloat, hiddenOffset: CGFloat, velocityY: CGFloat) -> PreviewDrawerState {
        guard hiddenOffset > 0 else { return .expanded }

        if velocityY <= -velocityThreshold {
            return .expanded
        }
        if velocityY >= velocityThreshold {
            return .hidden
        }

        let progress = currentOffset / hiddenOffset
        return progress < 0.5 ? .expanded : .hidden
    }
}
