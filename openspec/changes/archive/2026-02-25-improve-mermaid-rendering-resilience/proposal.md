## Why

Users can provide Mermaid blocks that are semantically valid for their source ecosystem but fail in the app's current iOS WebKit rendering path, resulting in fallback output and poor diagnosability. This change is needed now to improve rendering reliability without requiring any edits to user-authored Markdown content.

## What Changes

- Improve Mermaid rendering robustness by normalizing Mermaid source at render time (in-memory only) before passing it to Mermaid, while preserving original Markdown text.
- Pin Mermaid runtime to a verified concrete version to avoid behavior drift from floating CDN major tags.
- Expose actionable Mermaid parse/runtime errors in preview fallback UI and logging so syntax issues can be diagnosed quickly.
- Keep fallback behavior non-fatal for preview and export, ensuring one failed diagram does not block full-document rendering.
- Add coverage for compatibility edge cases and diagnostics behavior in renderer/export tests.

## Capabilities

### New Capabilities
- `mermaid-rendering-resilience`: Runtime compatibility and diagnostics safeguards for Mermaid blocks without modifying source Markdown.

### Modified Capabilities
- `markdown-extended-rendering`: Expand Mermaid rendering requirements to include compatibility normalization, deterministic runtime versioning, and visible diagnostics on failure.

## Impact

- Affected code: `md2jpeg/Services/HTMLTemplateBuilder.swift`, `md2jpeg/Services/MarkdownHTMLRenderer.swift`, Mermaid-related theme styles, preview/export readiness signaling, and Mermaid-focused tests.
- APIs/systems: WKWebView-based preview and background export rendering pipeline, bundled HTML/JS runtime, and OpenSpec capability docs.
- Dependencies: Mermaid CDN usage policy will move from floating major to pinned version semantics.
