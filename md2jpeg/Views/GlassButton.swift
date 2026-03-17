import SwiftUI

struct GlassButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 44
    var disabled: Bool = false

    @Environment(\.overlayColors) private var colors

    var body: some View {
        Button(action: action) {
            OverlaySurface(shapeStyle: .circle) {
                Image(systemName: icon)
                    .font(.system(size: size * 0.4, weight: .medium))
                    .foregroundStyle(colors.iconPrimary)
                    .frame(width: size, height: size)
                    .contentShape(Circle())
            }
        }
        .disabled(disabled)
        .opacity(disabled ? 0.4 : 1)
    }
}
