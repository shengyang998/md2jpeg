## Context

The app already supports Mermaid rendering with a pinned runtime and per-theme Mermaid configuration. Current styling is mostly global and does not provide strong visual hierarchy for mindmap nodes, and non-mindmap Mermaid diagrams can appear inconsistent across themes. We need a moderate styling upgrade that keeps the existing rendering pipeline intact and does not add new dependencies.

Constraints:
- Preview and export must remain visually consistent.
- Existing theme presets (`classic`, `paper`, `dark`) must continue to work.
- Mermaid rendering resilience behavior (fallback and diagnostics) must not regress.

## Goals / Non-Goals

**Goals:**
- Improve readability and perceived quality across Mermaid diagram types via theme-level customization.
- Add explicit hierarchy emphasis for mindmap diagrams while keeping a coherent cross-diagram palette baseline.
- Keep theming deterministic and compatible with the pinned Mermaid runtime.
- Ensure selected app theme drives Mermaid appearance consistently in preview and export.
- Keep scope moderate and implementation low-risk.

**Non-Goals:**
- Replacing Mermaid with another diagram engine.
- Introducing interactive/animated mindmap behavior.
- Reworking non-Mermaid markdown rendering.
- Large-scale visual redesign of the entire app theme system.

## Decisions

### Decision 1: Use layered theming (Mermaid config + CSS overrides)

We will split responsibilities:
- `themeVariables` handles Mermaid-native cross-diagram tokens (base colors, text, lines, background, typography baseline) for flowchart/sequence/class/state/ER/mindmap.
- Theme CSS files handle mindmap-specific visual polish on generated SVG elements (node fill/border emphasis, subtle depth cues, spacing feel), plus conservative normalization overrides for shared Mermaid SVG legibility.

Rationale:
- Mermaid-native config gives stable cross-diagram defaults.
- CSS can target diagram details that config alone cannot fully express, especially mindmap hierarchy and shared text/line legibility adjustments.
- This achieves meaningful visual improvement without changing renderer architecture.

Alternatives considered:
- **Only `themeVariables`**: lower complexity but limited expressive control for mindmap hierarchy emphasis and cross-diagram fine-tuning.
- **Custom renderer**: maximal control but high cost/risk, out of scope for moderate customization.

### Decision 2: Keep per-preset style identity

Each bundled preset will define a coherent Mermaid style profile:
- `classic`: clean neutral contrast and restrained emphasis.
- `paper`: warm low-contrast palette with soft borders.
- `dark`: higher-contrast strokes/text with preserved dark background balance.

Rationale:
- Aligns with existing theme selector expectations.
- Keeps diagrams visually integrated with document styling rather than appearing as foreign widgets.

Alternatives considered:
- **Single universal Mermaid style**: simpler but weak alignment with selected theme and lower perceived polish.

### Decision 3: Add fixture-backed validation for visual and compatibility safety

Use existing mermaid fixtures and add/adjust diagram coverage where needed to verify:
- Rendering succeeds for valid Mermaid sources across major diagram types.
- Mindmap hierarchy readability improves without harming other diagram readability.
- Fallback behavior remains unchanged for invalid content.
- Exported output reflects the selected theme and new Mermaid styling path.

Rationale:
- Styling changes can accidentally reduce contrast or break selector compatibility.
- Fixture checks reduce regression risk without introducing new testing infrastructure.

## Risks / Trade-offs

- [Mermaid SVG structure changes can break CSS selectors] -> Use conservative selectors, prefer stable class hooks, and keep Mermaid runtime pinned.
- [Increased per-theme styling complexity] -> Centralize token intent in Mermaid config and keep CSS overrides small and documented.
- [Visual regressions in one diagram type while improving another] -> Validate all three presets with fixtures spanning mindmap and other Mermaid diagram types.
- [Over-styling harms readability] -> Favor contrast and hierarchy first, decorative effects second.

## Migration Plan

No data migration is required.

Rollout plan:
1. Update Mermaid config JSON generation with refined per-theme variables.
2. Add targeted mindmap SVG style rules plus conservative shared Mermaid legibility rules to each bundled theme CSS.
3. Run markdown/mermaid fixture tests and preview/export checks for all themes and key diagram types.
4. If regressions are found, roll back by reverting theme-level Mermaid adjustments while keeping runtime and fallback logic unchanged.

## Open Questions

- Do we want one shared hierarchy intensity for mindmap across themes, or allow theme-specific hierarchy strength (for example stronger depth contrast in dark mode)?
- Should future work expose an advanced setting for diagram density/contrast, or remain fully preset-driven?
