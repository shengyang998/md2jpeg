import SwiftUI

/// Semantic colors for glass/material overlays that adapt to system appearance.
///
/// Usage:
///   - Use `controlChrome(isDarkBackground:)` for controls that sit directly
///     on top of editor/preview content.
///   - Use `statusSurface(for:)` for glass/material status surfaces whose
///     contrast should follow the system appearance.
struct OverlayColors {
    let isDarkBackground: Bool

    var iconPrimary: Color {
        isDarkBackground ? .white.opacity(0.96) : Color(white: 0.1)
    }

    var iconSecondary: Color {
        isDarkBackground ? .white.opacity(0.82) : Color(white: 0.16).opacity(0.72)
    }

    var labelPrimary: Color {
        isDarkBackground ? .white.opacity(0.96) : Color(white: 0.1)
    }

    var labelSecondary: Color {
        isDarkBackground ? .white.opacity(0.76) : Color(white: 0.22).opacity(0.82)
    }

    var segmentSelected: Color {
        isDarkBackground ? .white.opacity(0.98) : Color(white: 0.08)
    }

    var segmentNormal: Color {
        isDarkBackground ? .white.opacity(0.82) : Color(white: 0.14).opacity(0.76)
    }

    var segmentSelectedFill: Color {
        isDarkBackground ? .white.opacity(0.2) : Color.black.opacity(0.08)
    }
}

extension OverlayColors {
    static func controlChrome(isDarkBackground: Bool) -> OverlayColors {
        OverlayColors(isDarkBackground: isDarkBackground)
    }

    static func statusSurface(for colorScheme: ColorScheme) -> OverlayColors {
        OverlayColors(isDarkBackground: colorScheme == .dark)
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
