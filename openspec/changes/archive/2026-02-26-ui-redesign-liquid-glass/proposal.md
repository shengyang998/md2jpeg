## Why

The current UI splits attention between an editor panel, a bottom-sheet preview, and a toolbar row of buttons. This layout works but feels utilitarian and cluttered for an app whose sole purpose is "paste markdown → get image." A full-screen, single-surface design with floating glass controls would make the app feel focused, modern, and aligned with Apple's Liquid Glass design language. It also simplifies the interaction model to two clear modes (raw editing and preview) instead of simultaneous panels competing for space.

## What Changes

- **Remove** the navigation title bar, the horizontal toolbar row, and the bottom-sheet preview drawer.
- **Introduce** a full-screen content area that shows either the raw markdown editor or the rendered preview, never both at once.
- **Add** a floating bottom control bar with three elements: theme picker button (left), Raw/Preview segmented toggle (center), and export button (right).
- **Add** floating paste and clear buttons at the top-right corner, visible only in raw mode with fade animation.
- **Replace** the linear export progress indicator with a full-screen circular progress overlay.
- **Replace** the inline clear-button confirmation with an iOS Photos-style `.confirmationDialog`.
- **Replace** the always-visible format picker with a `.confirmationDialog` triggered by the export button (JPEG / PNG / HEIC).
- **Replace** the horizontal theme pill row with a popover triggered from the theme button.
- **Add** a blur-based morph transition animation when switching between raw and preview modes.
- **Apply** Liquid Glass aesthetic (`.ultraThinMaterial`, rounded glass shapes, spring animations) to all floating controls.

## Capabilities

### New Capabilities
- `full-screen-mode-toggle`: Full-screen raw/preview mode switching with blur morph transition animation
- `liquid-glass-controls`: Floating glass-material control bar and contextual action buttons
- `export-flow-modal`: Export format selection via confirmation dialog and full-screen circular progress overlay

### Modified Capabilities
- `preview-drawer-interaction`: **BREAKING** — The bottom-sheet preview drawer is removed entirely, replaced by full-screen preview mode behind the toggle.
- `markdown-image-export-ios`: Export trigger changes from toolbar button + inline format picker to confirmation dialog flow; progress display changes from linear to full-screen circular.
- `markdown-theme-presets`: Theme selection moves from horizontal pill row to a popover triggered by a floating glass button.

## Impact

- **Views**: `ContentView.swift` — major rewrite (layout, state machine, animations). `ThemePickerView.swift` — rewrite as popover. `MarkdownEditorView.swift` — minor (remove bottom inset logic). `MarkdownPreviewView.swift` — minor (remove drawer integration). New views for floating controls, circular progress overlay.
- **Removed**: `PreviewDrawerState.swift` — no longer needed. `ShareSheet.swift` — likely unused after flow change.
- **State**: `AppState` — add `isRawMode: Bool`. Remove preview-sheet and drawer state from `ContentView`.
- **Dependencies**: None new. Pure SwiftUI + existing UIKit interop.
- **Minimum target**: iOS 17 (use `.ultraThinMaterial` to approximate Liquid Glass; native `glassEffect` requires iOS 26).
