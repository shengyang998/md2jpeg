import SwiftUI

struct ThemePickerView: View {
    @Binding var selectedTheme: ThemePreset

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ThemePreset.allCases) { theme in
                    Button {
                        selectedTheme = theme
                    } label: {
                        Text(theme.displayName)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedTheme == theme ? Color.accentColor : Color(uiColor: .secondarySystemFill))
                            )
                            .foregroundStyle(selectedTheme == theme ? .white : .primary)
                    }
                }
            }
        }
    }
}
