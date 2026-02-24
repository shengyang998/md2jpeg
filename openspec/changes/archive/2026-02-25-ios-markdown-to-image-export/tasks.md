## 1. Project setup and app skeleton

- [x] 1.1 Create a new iOS app target and baseline module structure for editor, preview, theme, and export components
- [x] 1.2 Add Markdown-to-HTML rendering support and WebView integration for preview
- [x] 1.3 Establish shared app state model for markdown text, selected theme, and export format

## 2. Markdown input and live preview

- [x] 2.1 Implement editor UI for paste/edit markdown content
- [x] 2.2 Implement live preview pipeline that re-renders HTML when markdown changes
- [x] 2.3 Add user-visible loading/error states for preview rendering failures

## 3. Theme preset system

- [x] 3.1 Create bundled theme assets with at least three presets and stable theme identifiers
- [x] 3.2 Implement theme selector UI and apply selected theme to preview immediately
- [x] 3.3 Ensure exported rendering uses the currently selected theme

## 4. Single-image export pipeline

- [x] 4.1 Implement export action that always outputs one image file per request
- [x] 4.2 Add format encoders for `png`, `jpeg`, and `heic` with runtime HEIC fallback to JPEG
- [x] 4.3 Save successfully exported images directly to the system photo library

## 5. Memory-bounded long-document handling

- [x] 5.1 Define export dimension and pixel-budget limits used to guard memory usage
- [x] 5.2 Implement tiled/chunked rendering to avoid monolithic full-size in-memory buffers
- [x] 5.3 Add preflight size estimation and graceful export failure messaging when limits are exceeded
- [x] 5.4 Implement per-tile render-readiness checks with bounded retries before snapshot capture
- [x] 5.5 Add tile and composed-image completeness validation to reject partial exports

## 6. Verification and readiness

- [x] 6.1 Add tests for markdown-to-preview updates, theme switching, and export-format behavior
- [x] 6.2 Add stress tests for long-document export to validate memory safeguards
- [x] 6.3 Run manual QA checklist for preview/export parity and photo-library save flow on target iOS versions
- [x] 6.4 Add deterministic tests for tiling continuity and top-line coverage validation logic
- [x] 6.5 Add retryable error-path coverage for unstable/incomplete export capture handling
