## Why

Current Mermaid mindmap output is functional but visually flat and hard to scan, especially in exported images where node hierarchy and emphasis are not clear. Other Mermaid diagram types also lack a cohesive palette and can feel inconsistent with app theme identity. We need a moderate theming pass now so Mermaid output looks intentional, elegant, and readable across bundled themes without introducing a custom renderer.

## What Changes

- Refine Mermaid theming with a layered approach: shared cross-diagram palette tokens (for flowchart/sequence/class/state/ER/mindmap) plus mindmap-specific CSS emphasis.
- Define per-theme visual tokens (colors, borders, typography emphasis, spacing feel) so `classic`, `paper`, and `dark` each produce coherent Mermaid visuals across diagram types.
- Keep preview/export behavior aligned by applying the same Mermaid theming path in both rendering contexts.
- Keep implementation within current Mermaid runtime and rendering pipeline (no renderer replacement, no new third-party diagram engine).
- Adopt accessibility-aware contrast targets for text/lines/node fills so elegant styling does not reduce readability in light/dark modes.

### External Theme Research Direction

- Mermaid theming guidance supports `themeVariables`/`base` customization and diagram-wide token control, which matches our moderate-customization goal.
- Palette inspirations to evaluate for elegance and technical readability: Nord (cool restrained), Catppuccin (soft warm/cool variants), Tokyo Night (high-legibility dark accents), and neutral-first systems similar to GitHub Primer scales.
- Selection criteria: visual hierarchy in mindmaps, readability for dense diagrams, consistent look across diagram types, and robust contrast in export images.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `markdown-extended-rendering`: Mermaid fenced blocks will continue to render, with expanded requirements for (a) cross-diagram themed consistency and readability and (b) stronger mindmap hierarchy clarity in preview/export.
- `markdown-theme-presets`: Theme preset requirements will be expanded so Mermaid styling (including mindmap emphasis and other diagram baselines) is part of each bundled preset and remains consistent with selected theme identity.

## Impact

- Affected code: Mermaid config generation in `MarkdownHTMLRenderer`, HTML/JS render template integration in `HTMLTemplateBuilder`, and bundled theme CSS files under `md2jpeg/Resources/Themes/`.
- APIs: No external API changes.
- Dependencies: No new dependencies; continue using pinned Mermaid runtime.
- Risks: CSS selector coupling to Mermaid SVG structure, overfitting palette choices to one diagram type, and cross-theme contrast regressions; mitigated with fixture-based preview/export checks across multiple Mermaid diagram types.
