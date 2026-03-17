import SwiftUI

struct BlockingStatusOverlay<Content: View>: View {
    var width: CGFloat = 300
    var cornerRadius: CGFloat = 30
    var scrimOpacity: Double? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        OverlaySurface(
            shapeStyle: .roundedCard(cornerRadius: cornerRadius),
            borderOpacity: 0.24,
            shadowOpacity: 0.16,
            shadowRadius: 24,
            shadowY: 18,
            scrimOpacity: scrimOpacity
        ) {
            content()
                .padding(.horizontal, 30)
                .padding(.vertical, 32)
                .frame(width: width)
        }
        .padding(32)
        .allowsHitTesting(true)
    }
}
