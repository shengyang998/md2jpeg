## Why

The current split editing and preview experience limits focus: users cannot quickly switch between full-screen editing and full-screen preview. A draggable bottom drawer makes this interaction more natural on iOS by letting users reveal preview when needed and dismiss it to return to distraction-free editing.

## What Changes

- Replace the fixed preview pane behavior with a bottom drawer interaction for preview.
- Allow users to drag the preview drawer upward to expand into a full-screen preview state.
- Allow users to dismiss the drawer by dragging/scolling it back down to restore full-screen editing.
- Preserve markdown rendering behavior and existing preview content while changing container/presentation behavior.

## Capabilities

### New Capabilities
- `preview-drawer-interaction`: Supports a bottom-anchored, draggable preview drawer that can expand to full-screen preview and collapse to hidden for full-screen editing.

### Modified Capabilities
- `markdown-image-export-ios`: Update editor/preview interaction requirements to include drawer-based preview presentation and gesture-driven expansion/collapse.

## Impact

- Affected UI and interaction layer in the iOS app, primarily editor/preview container views and related state management.
- Potential updates to preview web view embedding, layout constraints, and gesture handling.
- Tests will need coverage for drawer states (collapsed/expanded), transitions, and editability when preview is hidden.
