## Context

The app converts markdown to HTML via a custom line-by-line parser (`MarkdownHTMLRenderer`), renders in a `WKWebView`, and snapshots for export. Inline formatting currently supports only `**bold**` and `` `code` `` via a naive `replaceDelimited` function that splits on a delimiter string and wraps odd-indexed segments. The HTML template already loads one CDN library (Mermaid) with timeout/fallback handling.

Two gaps exist: (1) no italic or bold-italic support despite `*` being fundamental markdown, and (2) no LaTeX math rendering for technical/scientific content.

## Goals / Non-Goals

**Goals:**
- Render `*italic*`, `**bold**`, and `***bold-italic***` correctly, including when they appear near each other in the same line
- Render inline math (`$...$`) and display math (`$$...$$`, including multi-line) via KaTeX
- Integrate KaTeX using the same CDN + fallback pattern established by Mermaid
- Ensure math renders correctly across all three themes (classic, paper, dark)
- Preserve export fidelity — math and styled text must appear in exported images

**Non-Goals:**
- Full CommonMark/GFM compliance for inline formatting (no links, images, strikethrough, nested emphasis across element boundaries)
- Underscore-based emphasis (`_italic_`, `__bold__`) — only `*` marks
- MathJax support or server-side LaTeX rendering
- LaTeX packages beyond KaTeX's built-in coverage
- Editor-side syntax highlighting for math or emphasis markers

## Decisions

### Decision 1: Regex-based inline formatting (replacing `replaceDelimited`)

**Choice:** Replace the `replaceDelimited` split-based approach with ordered regex replacements for inline formatting.

**Rationale:** The current `replaceDelimited` splits the entire string on a delimiter, which breaks when delimiters overlap (`*` vs `**` vs `***`). Regex with non-greedy matching and longest-delimiter-first ordering resolves this naturally.

**Processing order:**
1. `\*\*\*(.+?)\*\*\*` → `<strong><em>$1</em></strong>`
2. `\*\*(.+?)\*\*` → `<strong>$1</strong>`
3. `\*(.+?)\*` → `<em>$1</em>`
4. `` `(.+?)` `` → `<code>$1</code>` (existing, moved to regex)

**Alternatives considered:**
- Keep `replaceDelimited` and layer calls: Fragile, `***` requires a two-tag wrapper that the current function can't produce cleanly.
- Full AST-based inline parser: Over-engineered for the current feature set; can revisit if link/image support is added later.

### Decision 2: KaTeX via CDN for math rendering

**Choice:** Load KaTeX CSS and JS from `cdn.jsdelivr.net`, pinned to a specific version, following the same pattern as Mermaid.

**Rationale:** KaTeX renders ~100x faster than MathJax, produces HTML+CSS output (captured naturally by WKWebView snapshot), and is ~300KB total. The CDN pattern is proven by the existing Mermaid integration.

**Alternatives considered:**
- MathJax: Heavier (~1MB), slower rendering, SVG output can complicate snapshotting.
- Bundled KaTeX in the app: Increases app size; CDN with fallback is simpler and keeps the app lightweight.

### Decision 3: Math extraction before HTML escaping

**Choice:** Extract math expressions (`$...$` and `$$...$$`) from the raw text and replace with UUID placeholders before HTML escaping. After escaping and inline formatting, substitute placeholders back with KaTeX-compatible markup containing the raw (unescaped) LaTeX.

**Rationale:** LaTeX uses `<`, `>`, `&` which the HTML escaper would mangle. Placeholder extraction keeps the escaping pipeline intact while protecting math content.

**Flow:**
```
Raw text
  → extract math → placeholders + math map
  → escapeHTML(text with placeholders)
  → applyInlineFormatting(escaped text)
  → reinsert math as <span class="math-inline">...</span>
  → final HTML
```

**Alternatives considered:**
- Skip HTML escaping for lines containing math: Dangerous, could allow injection.
- Post-process to unescape math: Fragile, hard to reverse selective escaping.

### Decision 4: Display math as a block-level construct

**Choice:** Parse `$$...$$` (including multi-line) as a block-level construct in `stableMarkdownToHTML`, similar to code fences. Single-line `$$..$$` on one line and multi-line `$$` open/close on separate lines are both supported.

**Rationale:** Display math is semantically block-level (centered, separate paragraph). Parsing it at the block level avoids conflicts with inline `$...$` parsing and allows multi-line expressions like `\begin{aligned}`.

### Decision 5: KaTeX rendering in JavaScript, not Swift

**Choice:** Pass raw LaTeX to the browser in `data-latex` attributes on wrapper elements. A JavaScript block in the template calls `katex.render()` on each element after DOM load.

**Rationale:** KaTeX is a JavaScript library. Calling it from the WebView JS context is natural and avoids bridging complexity. The wrapper elements (`<span class="math-inline">`, `<div class="math-display">`) use `data-latex` attributes to carry the raw expression, keeping LaTeX out of the HTML text flow entirely.

## Risks / Trade-offs

- **CDN dependency for KaTeX** → Same risk as Mermaid. Mitigation: `onerror` handler on the script tag; if KaTeX fails to load, math wrapper elements remain visible with raw LaTeX as fallback text.
- **`$` false positives (e.g., `$5.00`)** → Mitigation: Require no whitespace immediately after opening `$` and no whitespace immediately before closing `$`. Single `$` on a line is not treated as math. Empty `$...$` is ignored.
- **Regex inline formatting is not CommonMark-complete** → Accepted trade-off. The app targets a practical subset of markdown; full spec compliance would require a proper parser. The regex approach handles the common cases correctly.
- **KaTeX bundle size (~300KB)** → Loaded via CDN so no app size impact. First-render may flash raw LaTeX while KaTeX loads. Mitigation: hide math elements via CSS until KaTeX marks them rendered.
- **Theme color mismatch for math** → Mitigation: Add explicit `.math-inline`, `.math-display` CSS rules to each theme file setting `color` to match body text.
