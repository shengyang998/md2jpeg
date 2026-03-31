## Implementation Tasks

- [x] Create `Domain/HistoryEntry.swift` — SwiftData `@Model` class with id (UUID), title (String), markdownText (String), themeName (String), createdAt (Date)
- [x] Create `Services/HistoryManager.swift` — `@MainActor` class that handles saving entries (auto-title from first line/heading), deleting entries, and fetching sorted by date
- [x] Update `App/md2jpegApp.swift` — Add `.modelContainer(for: HistoryEntry.self)` to the app scene
- [x] Create `Views/HistoryListView.swift` — Sheet view with liquid glass styling (GlassEffectContainer, OverlaySurface), showing entries as title + relative timestamp, tap to restore markdown + theme, swipe to delete
- [x] Update `Views/TopControlBar.swift` — Add history button (clock.arrow.circlepath icon) using GlassButton, add `onHistory` callback
- [x] Update `Views/ContentView.swift` — Wire up auto-save on paste (save before replacing), auto-save on export (save after success), present history sheet, handle restore (set markdownText + selectedTheme from entry)
