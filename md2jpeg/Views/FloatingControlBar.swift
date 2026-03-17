import SwiftUI

struct FloatingControlBar: View {
    @Binding var isRawMode: Bool
    @Binding var selectedTheme: ThemePreset
    let onExport: (ExportFormat) -> Void

    @Environment(\.overlayColors) private var colors

    private let themes = ThemePreset.allCases
    private let formats = ExportFormat.allCases

    var body: some View {
        GlassEffectContainer {
            HStack {
                Menu {
                    ForEach(themes) { theme in
                        Button {
                            selectedTheme = theme
                        } label: {
                            if selectedTheme == theme {
                                Label(theme.displayName, systemImage: "checkmark")
                            } else {
                                Text(theme.displayName)
                            }
                        }
                    }
                } label: {
                    OverlaySurface(shapeStyle: .circle) {
                        Image(systemName: "paintpalette")
                            .font(.system(size: 44 * 0.4, weight: .medium))
                            .foregroundStyle(colors.iconPrimary)
                            .frame(width: 44, height: 44)
                    }
                }

                Spacer()

                ModeToggle(isRawMode: $isRawMode)

                Spacer()

                Menu {
                    ForEach(formats) { format in
                        Button(format.displayName) {
                            onExport(format)
                        }
                    }
                } label: {
                    OverlaySurface(shapeStyle: .circle) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 44 * 0.4, weight: .medium))
                            .foregroundStyle(colors.iconPrimary)
                            .frame(width: 44, height: 44)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
