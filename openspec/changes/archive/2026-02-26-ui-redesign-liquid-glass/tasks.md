## 1. State & Infrastructure

- [x] 1.1 Add `isRawMode: Bool` to `AppState` with UserDefaults persistence (default: `true`)
- [x] 1.2 Remove `selectedFormat` from `AppState` (format is now chosen per-export via dialog)
- [x] 1.3 Delete `PreviewDrawerState.swift`

## 2. Reusable Glass UI Components

- [x] 2.1 Create `GlassButton.swift` — circular button with `.ultraThinMaterial` background, SF Symbol icon, configurable size and tint
- [x] 2.2 Create `ModeToggle.swift` — segmented "Raw / Preview" pill with sliding glass highlight capsule, spring animation on selection change, binding to `isRawMode`
- [x] 2.3 Create `FloatingControlBar.swift` — bottom HStack containing theme button (left), ModeToggle (center), export button (right), with `.ultraThinMaterial` capsule background

## 3. Export Progress Overlay

- [x] 3.1 Create `ExportProgressOverlay.swift` — full-screen `.ultraThinMaterial` overlay with circular `ProgressView`, percentage label, and fade-in/out transition

## 4. Theme Picker Popover

- [x] 4.1 Rewrite `ThemePickerView.swift` as a vertical list of theme names intended for popover presentation (remove horizontal scroll, capsule pills)

## 5. ContentView Rewrite

- [x] 5.1 Replace NavigationStack + VStack layout with a ZStack containing three layers: content, floating controls, export overlay
- [x] 5.2 Implement content layer: show `MarkdownEditorView` or `MarkdownPreviewView` based on `isRawMode`, with blur + opacity morph transition (blur 0↔12pt, opacity 0↔1, spring ~0.4s)
- [x] 5.3 Keep WKWebView alive in background when in raw mode (render HTML reactively on text/theme change even when preview is hidden)
- [x] 5.4 Add floating top-right paste and clear `GlassButton`s, visible only in raw mode with `.transition(.opacity.combined(with: .scale))`
- [x] 5.5 Wire paste button to replace `markdownText` with clipboard content
- [x] 5.6 Wire clear button to present `.confirmationDialog` with destructive "Delete All Content" action
- [x] 5.7 Add floating bottom `FloatingControlBar` with theme popover, mode toggle, and export button
- [x] 5.8 Wire theme button to show `.popover` containing the rewritten `ThemePickerView`
- [x] 5.9 Wire export button to present `.confirmationDialog` listing JPEG, PNG, HEIC format actions
- [x] 5.10 Wire format selection to trigger export and show `ExportProgressOverlay`
- [x] 5.11 Handle keyboard avoidance: bottom bar animates above keyboard in raw mode

## 6. Editor Cleanup

- [x] 6.1 Remove `bottomContentInset` parameter and related inset logic from `MarkdownEditorView.swift` and `InsetTextView`
- [x] 6.2 Remove `ShareSheet.swift` if no longer referenced

## 7. Polish & Verification

- [x] 7.1 Verify blur morph transition looks smooth on device (adjust duration/radius if needed)
- [x] 7.2 Verify export works correctly from both raw and preview mode (WebView must be loaded)
- [x] 7.3 Verify theme popover shows correctly on iPhone (adapts to sheet) and iPad (true popover)
- [x] 7.4 Verify clear confirmation dialog matches iOS Photos delete pattern
- [x] 7.5 Verify keyboard avoidance positions bottom bar correctly above keyboard
- [x] 7.6 Verify export progress overlay blocks interaction and shows real-time progress
