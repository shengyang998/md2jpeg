import SwiftUI

struct StatusToast: View {
    let message: String

    @Environment(\.overlayColors) private var colors

    var body: some View {
        OverlaySurface(
            shapeStyle: .capsule,
            borderOpacity: 0.14,
            shadowOpacity: 0.08,
            shadowRadius: 16,
            shadowY: 8
        ) {
            Text(message)
                .font(.footnote.weight(.medium))
                .foregroundStyle(colors.labelPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .allowsHitTesting(false)
    }
}
