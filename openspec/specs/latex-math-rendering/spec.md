## Requirements

### Requirement: Renderer supports inline LaTeX math
The system SHALL parse `$...$` delimiters in inline text and render the enclosed LaTeX expression as formatted math in preview and export contexts. The system SHALL NOT treat `$` as a math delimiter when immediately followed by whitespace (opening) or immediately preceded by whitespace (closing). Empty `$...$` pairs SHALL be ignored.

#### Scenario: Render inline math in preview
- **WHEN** a user enters text containing `$E = mc^2$`
- **THEN** the preview renders the expression as formatted math inline with the surrounding text

#### Scenario: Inline math preserved in export
- **WHEN** a user exports markdown containing inline math expressions
- **THEN** the exported image includes the rendered math at the correct inline positions

#### Scenario: Dollar sign not treated as math when adjacent to whitespace
- **WHEN** a user enters text containing `$ not math $` or `$5.00`
- **THEN** the preview renders the dollar signs as literal text, not as math delimiters

#### Scenario: Empty math delimiters ignored
- **WHEN** a user enters text containing `$$` with no content between the dollar signs on the same inline span
- **THEN** the preview renders the dollar signs as literal text

### Requirement: Renderer supports display LaTeX math
The system SHALL parse `$$...$$` blocks as display-level (block) math and render the enclosed LaTeX expression as a centered, standalone math block in preview and export contexts. Display math SHALL support multi-line content (opening `$$` and closing `$$` on separate lines).

#### Scenario: Render single-line display math in preview
- **WHEN** a user enters `$$\sum_{i=0}^{n} i$$` on a single line
- **THEN** the preview renders the expression as a centered block-level math element

#### Scenario: Render multi-line display math in preview
- **WHEN** a user enters `$$` on one line, followed by LaTeX content on subsequent lines, followed by `$$` on a closing line
- **THEN** the preview renders the full multi-line expression as a single centered block-level math element

#### Scenario: Display math preserved in export
- **WHEN** a user exports markdown containing display math blocks
- **THEN** the exported image includes the rendered math block at the correct document position

### Requirement: LaTeX content is not corrupted by HTML escaping
The system SHALL ensure that LaTeX source text is not HTML-escaped before being passed to the math rendering engine. Characters such as `<`, `>`, and `&` within math delimiters SHALL be preserved as-is for the renderer.

#### Scenario: LaTeX with angle brackets renders correctly
- **WHEN** a user enters `$x < y$` or `$A \to B$`
- **THEN** the preview renders the math correctly without treating `<` as an HTML tag

#### Scenario: LaTeX with ampersand renders correctly
- **WHEN** a user enters display math containing `&` (e.g., in `\begin{aligned}` environments)
- **THEN** the preview renders the alignment correctly

### Requirement: Math rendering uses theme-aware styling
The system SHALL render math expressions with font color and sizing consistent with the currently selected theme. Math text SHALL be legible against the theme's background color.

#### Scenario: Math is readable in dark theme
- **WHEN** a user selects the dark theme and enters math expressions
- **THEN** the math renders with light-colored text on the dark background

#### Scenario: Math is readable in light themes
- **WHEN** a user selects the classic or paper theme and enters math expressions
- **THEN** the math renders with dark-colored text on the light background

### Requirement: Math rendering failures are visible and non-fatal
The system SHALL keep rendering and export available when KaTeX fails to load or a math expression contains invalid LaTeX. The system SHALL display the raw LaTeX source as fallback text when rendering fails.

#### Scenario: KaTeX CDN fails to load
- **WHEN** the KaTeX library fails to load from CDN
- **THEN** math wrapper elements display the raw LaTeX source text as fallback
- **AND** the rest of the document renders normally

#### Scenario: Invalid LaTeX expression
- **WHEN** a math expression contains LaTeX that KaTeX cannot parse
- **THEN** the preview displays the raw LaTeX source for the failed expression
- **AND** other math expressions on the page render normally
