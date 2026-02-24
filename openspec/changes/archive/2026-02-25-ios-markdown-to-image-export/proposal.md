## Why

Mobile users who draft notes in Markdown need a fast way to turn content into polished, shareable images without desktop tools. Building an iOS-first Markdown-to-image workflow now enables a focused utility app with clear social-sharing value and room for future format presets.

## What Changes

- Create an iOS application where users can paste or edit Markdown and see a live rendered preview.
- Add a built-in theme system (Typora-inspired visual styles) with at least three bundled themes for quick switching.
- Add image export for `png`, `jpeg`, and `heic` outputs through a single-tap export flow and iOS share sheet integration.
- Define v1 long-document behavior as single-image export only, with internal memory-aware rendering safeguards and graceful failure messaging for oversized content.
- Defer multi-page export and social-platform page-size presets (for example, Xiaohongshu-optimized slicing) to a future change.

## Capabilities

### New Capabilities
- `markdown-image-export-ios`: iOS Markdown editing, themed preview rendering, and single-image export to `png`, `jpeg`, and `heic` with memory-safe handling.
- `markdown-theme-presets`: bundled visual theme selection for Markdown preview and export consistency.

### Modified Capabilities
- None.

## Impact

- Affected code: new iOS app codebase (UI, rendering pipeline, theme assets, export pipeline).
- APIs/systems: iOS system share sheet and image encoding stack (`png`/`jpeg`/`heic`).
- Dependencies: SwiftUI/UIKit + Web rendering and Markdown rendering support libraries as needed.
- Product behavior: v1 explicitly chooses single long-image export only and optimizes for stability over advanced pagination options.
