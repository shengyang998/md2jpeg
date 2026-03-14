## Why

The markdown renderer lacks support for italic/bold-italic text (`*`, `***`) and has no LaTeX math rendering. These are common in note-taking and technical writing workflows — italic emphasis is fundamental markdown, and LaTeX math is expected by anyone writing equations or formulas. Without them, the app can't faithfully render a significant portion of real-world markdown content.

## What Changes

- Add `*text*` italic rendering (`<em>`) to the inline formatting pipeline
- Add `***text***` bold-italic rendering (`<strong><em>`) to the inline formatting pipeline
- Refactor inline formatting from naive delimiter-splitting to regex-based processing (longest-delimiter-first) to correctly handle `*` / `**` / `***` overlap
- Add KaTeX integration via CDN for math rendering (same pattern as Mermaid)
- Parse `$...$` for inline math and `$$...$$` for display math (block-level, multi-line)
- Add math-aware CSS rules to each theme (classic, paper, dark) for proper font colors and sizing
- Handle the escaping problem: math content must not be HTML-escaped before KaTeX processes it

## Capabilities

### New Capabilities
- `latex-math-rendering`: Inline (`$...$`) and display (`$$...$$`) math rendering via KaTeX, including CDN loading, theme-aware styling, timeout/fallback handling, and correct interaction with HTML escaping

### Modified Capabilities
- `markdown-extended-rendering`: Add italic (`*text*`) and bold-italic (`***text***`) inline formatting support; refactor inline formatting to use regex-based processing for correct delimiter precedence

## Impact

- `md2jpeg/Services/MarkdownHTMLRenderer.swift` — inline formatting refactor (regex), new block-level `$$` parsing, math content extraction before HTML escaping
- `md2jpeg/Services/HTMLTemplateBuilder.swift` — KaTeX CDN script/CSS injection, KaTeX render script (similar to Mermaid init)
- `md2jpeg/Resources/Themes/theme-*.css` — math-specific styling rules for each theme
- New external dependency: KaTeX via CDN (CSS + JS, ~300KB)
- Export pipeline unaffected structurally — KaTeX renders to HTML+CSS so WKWebView snapshot captures it naturally
