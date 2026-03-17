import SwiftUI

struct TopControlBar: View {
    let showTitle: Bool
    let onPaste: () -> Void
    let onDeleteAll: () -> Void
    let isDeleteDisabled: Bool

    @Environment(\.overlayColors) private var colors

    var body: some View {
        GlassEffectContainer {
            HStack {
                Text("Markdown-Image")
                    .font(.caption.weight(.semibold))
                    .tracking(2)
                    .foregroundStyle(colors.labelPrimary.opacity(0.84))
                    .opacity(showTitle ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: showTitle)

                Spacer()

                GlassButton(icon: "doc.on.clipboard", action: onPaste)

                Menu {
                    Button("Delete All Content", role: .destructive) {
                        onDeleteAll()
                    }
                } label: {
                    OverlaySurface(shapeStyle: .circle) {
                        Image(systemName: "trash")
                            .font(.system(size: 44 * 0.4, weight: .medium))
                            .foregroundStyle(colors.iconPrimary)
                            .frame(width: 44, height: 44)
                    }
                }
                .disabled(isDeleteDisabled)
                .opacity(isDeleteDisabled ? 0.4 : 1)
            }
        }
    }
}
