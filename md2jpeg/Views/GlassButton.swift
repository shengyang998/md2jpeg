import SwiftUI

struct GlassButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 44
    var disabled: Bool = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .frame(width: size, height: size)
                .background(.ultraThinMaterial, in: Circle())
                .contentShape(Circle())
        }
        .disabled(disabled)
        .opacity(disabled ? 0.4 : 1)
    }
}
