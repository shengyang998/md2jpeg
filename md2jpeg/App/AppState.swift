import Foundation
internal import Combine

@MainActor
final class AppState: ObservableObject {
    private enum PersistenceKey {
        static let markdownText = "app.markdownText"
        static let selectedTheme = "app.selectedTheme"
        static let selectedFormat = "app.selectedFormat"
    }

    private static let defaultMarkdownText = """
    # Markdown to Image

    Paste your markdown here, pick a theme, and export one long image.

    - Supports **PNG**, **JPEG**, and **HEIC**
    - Preview reflects the selected theme
    - Export has memory-safe bounds for long content

    ```swift
    print("Hello, markdown image")
    ```
    """

    private let userDefaults: UserDefaults
    private var persistenceEnabled = false

    @Published var markdownText: String {
        didSet {
            guard persistenceEnabled else { return }
            userDefaults.set(markdownText, forKey: PersistenceKey.markdownText)
        }
    }
    @Published var selectedTheme: ThemePreset {
        didSet {
            guard persistenceEnabled else { return }
            userDefaults.set(selectedTheme.rawValue, forKey: PersistenceKey.selectedTheme)
        }
    }
    @Published var selectedFormat: ExportFormat {
        didSet {
            guard persistenceEnabled else { return }
            userDefaults.set(selectedFormat.rawValue, forKey: PersistenceKey.selectedFormat)
        }
    }

    @Published var isPreviewLoading: Bool = true
    @Published var previewErrorMessage: String?

    @Published var isExporting: Bool = false
    @Published var exportProgress: Double = 0
    @Published var exportErrorMessage: String?
    @Published var exportInfoMessage: String?
    @Published var exportedFileURL: URL?

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.markdownText = userDefaults.string(forKey: PersistenceKey.markdownText) ?? Self.defaultMarkdownText
        if let themeRawValue = userDefaults.string(forKey: PersistenceKey.selectedTheme),
           let restoredTheme = ThemePreset(rawValue: themeRawValue) {
            self.selectedTheme = restoredTheme
        } else {
            self.selectedTheme = .classic
        }

        if let formatRawValue = userDefaults.string(forKey: PersistenceKey.selectedFormat),
           let restoredFormat = ExportFormat(rawValue: formatRawValue) {
            self.selectedFormat = restoredFormat
        } else {
            // JPEG is the first-run default.
            self.selectedFormat = .jpeg
        }

        self.persistenceEnabled = true
    }
}
