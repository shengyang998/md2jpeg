## Context

The app renders Markdown into HTML via a deterministic Swift renderer, then uses WKWebView and Mermaid JS to render diagram blocks for both preview and export. Mermaid currently runs from a floating CDN major version and failures are collapsed into a generic fallback message, which makes compatibility regressions and syntax diagnostics hard to identify. The primary constraint is to preserve user-authored Markdown exactly as entered while improving render reliability across WebKit and Mermaid parser variations.

## Goals / Non-Goals

**Goals:**
- Improve Mermaid render success for commonly valid source patterns without requiring edits to source Markdown.
- Reduce parser behavior drift by pinning Mermaid runtime to a concrete validated version.
- Surface actionable failure diagnostics in preview/export fallback and logs.
- Preserve non-fatal fallback semantics and existing export readiness guarantees.
- Add deterministic tests around normalization, version pinning, and diagnostics.

**Non-Goals:**
- Full normalization for every Mermaid grammar extension or plugin.
- Semantic rewriting of user intent beyond conservative compatibility transforms.
- Interactive diagram features (zoom/pan/editing).
- Redesign of current markdown editor, preview, or export UX.

## Decisions

1. Introduce an in-memory Mermaid source normalization pass before `mermaid.render`.
   - Rationale: The source Markdown must remain unchanged, but runtime can still apply conservative transforms that improve parser compatibility (e.g., canonicalizing known equivalent syntactic forms).
   - Alternatives considered:
     - Require users to rewrite source manually: rejected due to unacceptable authoring burden.
     - Leave source untouched and rely only on fallback: rejected due to low rendering success and poor UX.

2. Pin Mermaid runtime to an explicit version rather than floating `@10`.
   - Rationale: Floating major tags can introduce parser behavior changes that regress rendering without app code changes.
   - Alternatives considered:
     - Keep floating major for automatic updates: rejected due to nondeterministic behavior.
     - Bundle a local Mermaid copy immediately: deferred; pinning CDN version is lower-effort first step.

3. Preserve non-fatal fallback while exposing concrete diagnostics.
   - Rationale: A failed Mermaid block must not block whole-document preview/export, but users need actionable error context.
   - Alternatives considered:
     - Fail entire render/export on Mermaid error: rejected due to poor resilience.
     - Keep generic fallback only: rejected due to weak debuggability.

4. Keep export readiness synchronized with Mermaid completion or timeout.
   - Rationale: Export snapshots must continue waiting for Mermaid completion state (rendered or fallback) to avoid partial capture.
   - Alternatives considered:
     - Snapshot immediately after HTML load: rejected due to race conditions and missing diagrams.

## Risks / Trade-offs

- [Normalization may alter edge-case diagrams unexpectedly] -> Mitigation: restrict transforms to conservative, opt-in rules and keep raw source visible in fallback.
- [Pinned Mermaid version may miss upstream fixes] -> Mitigation: track version in one constant and add a validation checklist for periodic upgrades.
- [Detailed error text may be noisy for end users] -> Mitigation: show concise user-facing message and keep full parser details in debug/log channels.
- [Additional preprocessing may impact render latency on long documents] -> Mitigation: keep normalization linear-time and scoped to Mermaid blocks only.
