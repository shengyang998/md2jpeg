## Context

The app currently renders Markdown for preview and single-image export, but advanced constructs are not consistently supported. Two high-value gaps are GitHub-style tables and Mermaid diagram blocks. This change spans multiple modules: Markdown parsing configuration, web view rendering behavior, export capture consistency, and QA coverage. The design must preserve existing export stability guarantees (including memory-bounded behavior and full-content capture) while adding richer rendering features.

## Goals / Non-Goals

**Goals:**
- Render Markdown tables consistently in preview and exported image output.
- Render Mermaid fenced blocks as diagrams in preview and export.
- Provide deterministic fallback behavior when Mermaid rendering fails (invalid syntax, runtime load failure, or timeout).
- Keep export behavior aligned with existing single-image and completeness requirements.
- Add test and QA coverage for new rendering paths.

**Non-Goals:**
- Full support for every Mermaid extension or third-party plugin.
- Interactive Mermaid behavior (zoom/pan/live editing) in rendered output.
- Redesign of current editor/export UI flows.
- Refactor of unrelated Markdown theme preset behavior.

## Decisions

1. Use parser-level table support in the Markdown pipeline.
   - Rationale: Table syntax should be normalized during Markdown parsing rather than post-processing HTML; this gives predictable output across preview and export.
   - Alternatives considered:
     - HTML post-transform for table patterns: rejected due to brittle handling of edge cases and escaping.
     - Custom table parser: rejected due to maintenance burden.

2. Render Mermaid through a controlled web runtime in the same rendering surface used for export.
   - Rationale: Using one rendering surface for preview and export minimizes divergence in what users see versus what gets saved.
   - Alternatives considered:
     - Native Mermaid rendering library on iOS: rejected due to limited ecosystem maturity and extra integration complexity.
     - Server-side render: rejected due to offline requirements and privacy concerns.

3. Treat Mermaid render failures as non-fatal with explicit placeholder/error output.
   - Rationale: Export should remain deterministic; a single invalid diagram should not block entire document export.
   - Alternatives considered:
     - Fail whole render/export on Mermaid error: rejected due to poor UX for mixed valid content.
     - Silently omit failed diagrams: rejected because it risks unnoticed data loss.

4. Add render-complete synchronization before export capture.
   - Rationale: Mermaid rendering may be asynchronous; export should wait for diagram render completion or timeout fallback before snapshotting.
   - Alternatives considered:
     - Capture immediately after Markdown render: rejected due to race conditions and incomplete diagrams.

5. Scope capability changes as one new capability plus one modified existing capability.
   - Rationale: New feature area (`markdown-extended-rendering`) defines new behavior cleanly, while `markdown-image-export-ios` captures compatibility deltas for existing export guarantees.

## Risks / Trade-offs

- [Mermaid runtime script load issues] -> Mitigation: bundle/version-pin runtime where possible and define timeout fallback content.
- [Asynchronous diagram rendering introduces export timing flakiness] -> Mitigation: explicit render-complete signal with bounded timeout and test fixtures for slow renders.
- [Large diagrams may increase memory pressure during long export] -> Mitigation: keep existing memory guards and add test docs combining long content plus diagrams.
- [Renderer differences across iOS/WebKit versions] -> Mitigation: constrain supported Mermaid feature subset and add compatibility tests on target OS versions.
- [Sanitization/security concerns for embedded diagram text] -> Mitigation: preserve strict content sanitization and avoid untrusted script execution paths beyond bundled Mermaid runtime.
