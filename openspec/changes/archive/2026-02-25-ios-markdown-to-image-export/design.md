## Context

The change introduces a new iOS utility app that converts Markdown into themed images for social sharing. The product constraint for v1 is intentionally simple user flow: edit/paste Markdown, choose theme, export one image. The major technical constraint is long-document memory pressure during export; the product explicitly requires single very tall image export only in v1, without paging options.

The repository currently has no iOS implementation, so architecture and module boundaries can be established cleanly from the start. Platform integrations include iOS rendering, image encoding (`png`, `jpeg`, `heic`), and system sharing.

## Goals / Non-Goals

**Goals:**
- Provide a one-screen workflow for Markdown input, themed preview, and export.
- Ensure visual consistency between preview and exported image.
- Support `png`, `jpeg`, and `heic` outputs through a single-image export pipeline.
- Handle large/long Markdown documents with memory-aware rendering and explicit failure boundaries.
- Keep implementation modular enough to add paged export and social-size presets later.

**Non-Goals:**
- Multi-page or auto-split export in v1.
- Social-platform-specific page size presets (for example, Xiaohongshu slices) in v1.
- Cloud sync, collaboration, or advanced template marketplace features.
- Full custom theme authoring by end users in v1.

## Decisions

### Rendering approach: HTML + CSS in WebView-backed preview/export
- **Decision:** Render Markdown to HTML and apply bundled CSS themes in a web view for both preview and export source.
- **Rationale:** This gives Typora-like theming flexibility, high parity between what users see and what they export, and fast iteration on visual style by editing CSS assets.
- **Alternatives considered:**
  - Native attributed-text rendering: easier memory control but weaker theme expressiveness and markdown feature parity.
  - Server-side rendering: rejected due to offline requirement and privacy concerns.

### Theme system: bundled, versioned presets
- **Decision:** Ship at least three bundled themes with a stable theme identifier model.
- **Rationale:** Predictable output, no runtime theme fetches, and straightforward QA for export parity.
- **Alternatives considered:**
  - User-provided custom CSS in v1: rejected to minimize complexity and support burden.

### Export behavior: single long image only in v1
- **Decision:** Export always produces one image file; no user prompt to choose split mode.
- **Rationale:** Matches product simplicity requirement and reduces UI surface area.
- **Alternatives considered:**
  - User-selectable single vs split: deferred because split mode requires platform-specific page-size logic and introduces product complexity not needed for v1.

### Memory safety strategy: tiled render + bounded pipeline
- **Decision:** Implement export with bounded memory usage by rendering content in vertical tiles and composing output while reusing buffers.
- **Rationale:** A single monolithic bitmap for very long content can exceed available RAM and terminate the app.
- **Key behaviors:**
  - Define safe export width presets and maximum pixel budget.
  - Detect estimated render size before export.
  - Use chunked/tiled drawing and autorelease boundaries to avoid simultaneous full-size buffers.
  - Emit user-facing errors when content exceeds safe limits.
- **Alternatives considered:**
  - No bounds and best-effort capture: rejected due to high crash risk.
  - Forced downscaling always: rejected because it degrades readability and user trust.

### Rendering reliability strategy: readiness checks + completeness validation
- **Decision:** Require deterministic render-readiness checks before each tile snapshot and validate tile/composition completeness before final export.
- **Rationale:** WebView rendering is asynchronous, and scrolling plus immediate snapshot can intermittently miss top content or produce partial tiles.
- **Key behaviors:**
  - Block export while preview is actively rendering.
  - Wait for document-readiness and scroll-settle conditions with bounded retries per tile.
  - Validate tile dimensions against expected bounds before composing.
  - Validate final coverage from top to bottom before encoding output.
  - Return explicit retryable errors when capture quality is unsafe.
- **Alternatives considered:**
  - Rely on `layoutIfNeeded()` and one event-loop yield: rejected due to nondeterministic capture timing.
  - Fallback to one full-page snapshot: rejected because it conflicts with long-document memory constraints.

### Future extensibility boundary for paged export
- **Decision:** Separate renderer, single-image exporter, and format encoder interfaces.
- **Rationale:** Enables future `Auto split pages` and social-size presets without rewriting preview/theming.
- **Alternatives considered:**
  - Single tightly coupled exporter: faster initially but high refactor cost for future page-aware export.

## Risks / Trade-offs

- **[Very long content still exceeds practical limits]** -> Mitigation: enforce maximum pixel budget with clear error messaging and guidance.
- **[WebView export parity drift across iOS versions]** -> Mitigation: test matrix across target iOS versions and include visual regression fixtures.
- **[Scroll-to-render race causes missing first lines]** -> Mitigation: per-tile readiness waits, first-tile stabilization, and completeness validation checks.
- **[HEIC encoding capability varies by device/runtime path]** -> Mitigation: runtime capability check with automatic fallback to JPEG and user notification.
- **[Tiled pipeline increases implementation complexity]** -> Mitigation: isolate exporter module and add deterministic stress tests for long documents.
