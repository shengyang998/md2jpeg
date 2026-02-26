## Context

The app currently uses a vertically-stacked layout: a toolbar row (paste, clear, format picker, export), a theme pill row, a UITextView editor, and a persistent bottom-sheet preview drawer backed by WKWebView. State is managed through a centralized `AppState` ObservableObject with `@Published` properties persisted to UserDefaults.

This redesign replaces that layout with a full-screen single-surface UI. The editor and preview occupy the same space, toggled by a segmented control. Floating glass-material buttons provide all actions. The visual language shifts to Apple's Liquid Glass aesthetic.

## Goals / Non-Goals

**Goals:**
- Single full-screen content area with raw/preview mode toggle
- Floating Liquid Glass controls (bottom bar: theme, toggle, export; top-right: paste, clear)
- Blur-based morph transition between raw and preview modes
- iOS Photos-style confirmation dialog for clear action
- Confirmation dialog for export format selection (JPEG/PNG/HEIC)
- Full-screen circular progress overlay during export
- Theme selection via popover from floating button
- Contextual top-right buttons: paste/clear visible only in raw mode

**Non-Goals:**
- Native iOS 26 `glassEffect` modifier (target remains iOS 17+; approximate with `.ultraThinMaterial`)
- Custom accent color picker or new theme presets (existing 3 themes stay)
- Changes to the markdown parser, HTML renderer, or export pipeline internals
- Split-view or simultaneous editor + preview layout
- Share sheet or "Save to Files" export destination (Photos only for now)

## Decisions

### 1. Mode toggle as the primary interaction

**Decision**: Use a two-segment pill control (`Raw | Preview`) at bottom-center. Active segment indicated by a sliding glass highlight capsule with spring animation.

**Alternatives considered**:
- Swipe gesture to switch modes — discoverability problem; conflicts with text scrolling.
- Tab bar — too heavy for two states; wastes vertical space.

**Rationale**: A segmented toggle is instantly understandable, thumb-reachable at the bottom, and leaves the full screen for content.

### 2. Blur morph transition

**Decision**: Switching modes uses a blur-based crossfade. The outgoing view blurs (0 → 12pt radius) while fading out; the incoming view simultaneously sharpens (12pt → 0) while fading in. Total duration ~0.4s with `.spring(response: 0.4, dampingFraction: 0.85)`.

**Alternatives considered**:
- Simple crossfade — too flat, doesn't feel "glass."
- Matched geometry transition — impractical across UITextView/WKWebView rendering engines.
- Slide transition — feels like page navigation, wrong mental model.

**Rationale**: Blur evokes the frosted glass aesthetic and masks the fact that two completely different rendering engines are swapping. It's cheap to implement with SwiftUI's `.blur(radius:)` and `.opacity()` modifiers.

### 3. Floating controls with glass material

**Decision**: All controls float over the content using `ZStack` overlay. Bottom bar is a single `HStack` inside a capsule-shaped `.ultraThinMaterial` background. Top-right buttons are individual circles with the same material. The bottom bar is always visible; top-right buttons animate in/out with raw mode using `.transition(.opacity.combined(with: .scale))`.

**Alternatives considered**:
- Fixed toolbar regions (top/bottom safe area) — consumes layout space, not "floating."
- Overlay only when idle / auto-hide — too clever; users lose track of controls.

**Rationale**: Floating glass controls stay visible without consuming layout space. The material lets content show through, reinforcing the single-surface metaphor.

### 4. Theme picker as popover

**Decision**: Tapping the theme button shows a `.popover` anchored to the button. The popover contains a vertical list of theme names. Tapping a theme applies it immediately and dismisses the popover.

**Rationale**: Popover is the lightest standard component for a short list. No layout shift, no navigation, system-standard behavior.

### 5. Export flow: confirmation dialog → circular progress

**Decision**: Tapping the export button presents a `.confirmationDialog` with three format actions (JPEG, PNG, HEIC) plus Cancel. On selection, a full-screen overlay with a `ProgressView(.circular)` and percentage label appears. The overlay uses `.ultraThinMaterial` background so the content is dimly visible behind it.

**Alternatives considered**:
- Bottom sheet with richer UI — over-designed for a 3-option choice.
- Inline progress in the export button — too small; export can take several seconds for long documents.

**Rationale**: Confirmation dialog matches the delete pattern (consistency). Full-screen progress gives clear feedback and prevents accidental interactions during export.

### 6. State management

**Decision**: Add `isRawMode: Bool` to `AppState` (persisted to UserDefaults, default `true`). Remove all preview-sheet and drawer-related state from `ContentView`. Add `isExportProgressVisible: Bool` as local `@State` in `ContentView` (not persisted — always resets to false).

**Rationale**: Minimal state change. The mode is a first-class user preference worth persisting. Export overlay is transient UI state.

### 7. View architecture

**Decision**: `ContentView` becomes a `ZStack` with three layers:

```
ZStack {
    // Layer 1: Content (raw or preview, with blur transition)
    // Layer 2: Floating controls (bottom bar + conditional top-right buttons)
    // Layer 3: Export progress overlay (conditional)
}
```

New view files:
- `FloatingControlBar.swift` — bottom bar with theme, toggle, export
- `GlassButton.swift` — reusable circular glass-material button
- `ModeToggle.swift` — segmented Raw/Preview pill with sliding highlight
- `ExportProgressOverlay.swift` — full-screen circular progress

Existing views modified:
- `ContentView.swift` — rewritten to ZStack layout
- `ThemePickerView.swift` — rewritten as popover list content
- `MarkdownEditorView.swift` — remove `bottomContentInset` logic

Removed:
- `PreviewDrawerState.swift`

## Risks / Trade-offs

- **[Risk] WKWebView load time visible during mode switch** → Mitigation: Keep the WKWebView alive and loaded in background even in raw mode. Only toggle visibility. HTML is already rendered reactively on text change.

- **[Risk] Blur animation feels janky on older devices** → Mitigation: Use a shorter animation duration (0.3s) as fallback if needed. The blur radius is modest (12pt) which performs well.

- **[Risk] Keyboard overlaps floating bottom bar in raw mode** → Mitigation: The bottom bar should move above the keyboard using `.ignoresSafeArea(.keyboard)` on the content and keyboard-aware padding on the bar. Use `GeometryReader` with keyboard height from `UIResponder` notifications if needed.

- **[Trade-off] Popover on iPhone shows as a sheet** → On iPhone, SwiftUI `.popover` automatically adapts to a sheet presentation. This is acceptable — it's still a clean, minimal interaction.

- **[Trade-off] No simultaneous editor + preview** → Users lose the ability to see both at once. This is an intentional simplification aligned with the "one thing at a time" design philosophy.
