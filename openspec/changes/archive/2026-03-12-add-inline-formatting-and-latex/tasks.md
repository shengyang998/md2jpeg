## 1. Inline Formatting Refactor (Bold / Italic / Bold-Italic)

- [x] 1.1 Replace `replaceDelimited` usage in `applyInlineFormatting` with regex-based replacements processing `***`, `**`, `*`, and `` ` `` in longest-delimiter-first order
- [x] 1.2 Remove the now-unused `replaceDelimited` method from `MarkdownHTMLRenderer`
- [x] 1.3 Add unit tests for italic (`*text*`), bold-italic (`***text***`), mixed emphasis on the same line, and edge cases (unmatched `*`, adjacent delimiters)

## 2. Display Math Block Parsing

- [x] 2.1 Add `$$...$$` block-level parsing to `stableMarkdownToHTML` — detect opening/closing `$$` lines and collect content (similar to code fence handling), emitting `<div class="math-display" data-latex="...">` with raw (unescaped) LaTeX in the data attribute and fallback text content
- [x] 2.2 Handle single-line display math (`$$expression$$` on one line) as a block-level element
- [x] 2.3 Add unit tests for multi-line display math, single-line display math, and empty `$$$$` (ignored)

## 3. Inline Math Extraction and Placeholder Pipeline

- [x] 3.1 Implement math extraction function: scan raw text for `$...$`, replace with UUID placeholders, and return a map of placeholder→raw LaTeX. Apply the whitespace heuristic (no space after opening `$`, no space before closing `$`) to avoid false positives like `$5.00`
- [x] 3.2 Implement placeholder reinsertion function: after HTML escaping and inline formatting, substitute placeholders back with `<span class="math-inline" data-latex="...">` containing raw LaTeX as fallback text
- [x] 3.3 Update the rendering pipeline in `stableMarkdownToHTML` to call math extraction before `escapeHTML` and reinsertion after `applyInlineFormatting` for paragraph, heading, list item, and table cell content
- [x] 3.4 Add unit tests for inline math extraction, placeholder reinsertion, `$` false-positive rejection, and LaTeX containing `<`, `>`, `&`

## 4. KaTeX Integration in HTML Template

- [x] 4.1 Add KaTeX CSS and JS CDN links (pinned version) to `HTMLTemplateBuilder`, with `onerror` fallback handler on the script tag (same pattern as Mermaid)
- [x] 4.2 Add JavaScript block that iterates `.math-inline` and `.math-display` elements, calling `katex.render()` with the `data-latex` attribute value. Handle render errors by leaving the fallback LaTeX text visible
- [x] 4.3 Coordinate KaTeX rendering with the existing `data-md2jpeg-ready` signaling — ensure ready is not set until both Mermaid and KaTeX rendering complete

## 5. Theme CSS for Math

- [x] 5.1 Add `.math-inline` and `.math-display` CSS rules to `theme-classic.css`, `theme-paper.css`, and `theme-dark.css` — set `color` to match body text, font sizing, and display-math centering/margin
- [x] 5.2 Add a CSS rule to hide math element content initially (pre-KaTeX render) and reveal after KaTeX processes them, to avoid raw LaTeX flash

## 6. Verification

- [x] 6.1 Verify bold, italic, bold-italic, inline math, and display math render correctly in preview across all three themes
- [x] 6.2 Verify exported images include rendered math and emphasis formatting
- [x] 6.3 Verify fallback behavior when KaTeX CDN is unavailable (raw LaTeX visible, no crash)
