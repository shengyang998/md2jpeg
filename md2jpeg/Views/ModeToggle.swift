import SwiftUI

struct ModeToggle: View {
    @Binding var isRawMode: Bool

    var body: some View {
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
        .background(.ultraThinMaterial.opacity(0.6), in: Capsule())
    }

    private func segmentButton(icon: String, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Label(title, systemImage: icon)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule()
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
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
