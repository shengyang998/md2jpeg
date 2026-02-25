## 1. Mermaid theme token refinement

- [x] 1.1 Update `MarkdownHTMLRenderer.mermaidConfigJSON(for:)` with refined per-theme Mermaid variables that improve cross-diagram readability while preserving existing fallback/runtime settings.
- [x] 1.2 Verify Mermaid config output remains valid JSON for `classic`, `paper`, and `dark`.

## 2. Theme CSS Mermaid styling

- [x] 2.1 Add shared Mermaid SVG legibility overrides plus mindmap hierarchy emphasis rules to `theme-classic.css`.
- [x] 2.2 Add shared Mermaid SVG legibility overrides plus mindmap hierarchy emphasis rules to `theme-paper.css`.
- [x] 2.3 Add shared Mermaid SVG legibility overrides plus mindmap hierarchy emphasis rules to `theme-dark.css`.

## 3. Preview/export consistency checks

- [x] 3.1 Validate that theme switching updates rendered Mermaid diagrams in preview without manual reload.
- [x] 3.2 Validate exported images preserve the selected preset's Mermaid styling characteristics across mindmap and non-mindmap diagrams.
- [x] 3.3 Confirm Mermaid fallback and diagnostics behavior remains unchanged for invalid diagrams.

## 4. Fixture and regression coverage

- [x] 4.1 Review existing Mermaid fixtures and add or adjust fixtures covering mindmap and at least one non-mindmap diagram type if coverage is insufficient.
- [x] 4.2 Update/extend relevant tests to assert themed Mermaid rendering, mindmap hierarchy readability, and cross-theme stability.
- [ ] 4.3 Run test suite segments covering markdown rendering, Mermaid compatibility, and export paths.
