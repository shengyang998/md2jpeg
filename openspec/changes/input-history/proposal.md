## Why

Users paste or type markdown content into the editor, but once they paste new content the previous input is lost. There's no way to go back to something you worked on earlier. A history feature gives users confidence to experiment — they can always retrieve past inputs.

## What Changes

Add an auto-save history system that captures markdown content + theme on every paste and export action. History is browsable via a new sheet accessible from the top control bar, styled with the app's existing liquid glass design language.

## Capabilities

### New Capabilities

- **Auto-save history**: Automatically snapshots current markdown + theme before paste replaces content, and after successful export
- **History list view**: Sheet with liquid glass styling showing saved entries (title, relative timestamp), tap to restore, swipe to delete
- **Full state restore**: Loading a history entry restores both the markdown text and the theme preset

### Modified Capabilities

- **TopControlBar**: New history button (clock.arrow.circlepath icon) using existing GlassButton
- **Paste action**: Now auto-saves current content before replacing
- **Export action**: Now auto-saves content after successful export
- **App initialization**: ModelContainer added for SwiftData persistence

## Impact

- No changes to the rendering pipeline or export system
- AppState gains a dependency on the history manager but remains otherwise unchanged
- Existing UserDefaults persistence for current editor state is unaffected
- SwiftData adds a lightweight SQLite store managed by the system — no manual migration needed
