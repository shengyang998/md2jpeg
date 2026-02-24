import Foundation

enum ThemePreset: String, CaseIterable, Identifiable {
    case classic
    case paper
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic:
            return "Classic"
        case .paper:
            return "Paper"
        case .dark:
            return "Dark"
        }
    }

    var cssFileName: String {
        "theme-\(rawValue)"
    }
}
