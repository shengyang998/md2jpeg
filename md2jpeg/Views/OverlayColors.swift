import SwiftUI

/// Semantic colors for overlay controls that adapt to both system appearance
/// and preview theme background.
///
/// Usage:
///   - In edit mode, pass `isDarkBackground` based on system `colorScheme`.
///   - In preview mode, pass `isDarkBackground` based on `ThemePreset.isDarkAppearance`.
struct OverlayColors {
    let isDarkBackground: Bool

    var iconPrimary: Color {
        isDarkBackground ? .white : Color(white: 0.12)
    }

    var iconSecondary: Color {
        isDarkBackground ? .white.opacity(0.7) : Color(white: 0.12).opacity(0.55)
    }

    var labelPrimary: Color {
        isDarkBackground ? .white : Color(white: 0.1)
    }

    var labelSecondary: Color {
        isDarkBackground ? .white.opacity(0.55) : Color(white: 0.35)
    }

    var segmentSelected: Color {
        isDarkBackground ? .white : Color(white: 0.12)
    }

    var segmentNormal: Color {
        isDarkBackground ? .white.opacity(0.65) : Color(white: 0.12).opacity(0.55)
    }
}

// MARK: - Environment

private struct OverlayColorsKey: EnvironmentKey {
    static let defaultValue = OverlayColors(isDarkBackground: false)
}

extension EnvironmentValues {
    var overlayColors: OverlayColors {
        get { self[OverlayColorsKey.self] }
        set { self[OverlayColorsKey.self] = newValue }
    }
}
