import SwiftUI

struct ModeToggle: View {
    @Binding var isRawMode: Bool

    @Environment(\.overlayColors) private var colors

    var body: some View {
        OverlaySurface(shapeStyle: .capsule) {
            HStack(spacing: 0) {
                segmentButton(
                    icon: "chevron.left.forwardslash.chevron.right",
                    title: "RAW",
                    isSelected: isRawMode
                ) {
                    isRawMode = true
                }

                segmentButton(
                    icon: "eye",
                    title: "PREV",
                    isSelected: !isRawMode
                ) {
                    isRawMode = false
                }
            }
            .padding(4)
        }
    }

    private func segmentButton(icon: String, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Label(title, systemImage: icon)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isSelected ? colors.segmentSelected : colors.segmentNormal)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule()
                        .fill(colors.segmentSelectedFill)
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 1)
                        .matchedGeometryEffect(id: "activeSegment", in: toggleNamespace)
                }
            }
            .contentShape(Capsule())
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    action()
                }
            }
    }

    @Namespace private var toggleNamespace
}
