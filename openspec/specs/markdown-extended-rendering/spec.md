## Requirements

### Requirement: Renderer supports GitHub-style Markdown tables
The system SHALL parse and render GitHub-style Markdown table syntax into structured table output in preview and export rendering contexts.

#### Scenario: Render basic table in preview
- **WHEN** a user enters Markdown containing a valid header row, delimiter row, and body rows
- **THEN** the preview shows a structured table with aligned columns and visible cell boundaries

#### Scenario: Preserve table in exported image
- **WHEN** a user exports Markdown containing a rendered table
- **THEN** the exported single image includes the table content without dropping rows or columns

### Requirement: Renderer supports Mermaid fenced code blocks
The system SHALL detect fenced code blocks marked as `mermaid` and render them as diagram visuals in preview and export rendering contexts. The system SHALL run Mermaid source through a compatibility normalization stage before rendering, without mutating the underlying Markdown document content.

#### Scenario: Render mermaid flowchart in preview
- **WHEN** a user enters a valid Mermaid fenced block
- **THEN** the preview shows a rendered diagram instead of raw Mermaid source text

#### Scenario: Preserve rendered mermaid diagram in exported image
- **WHEN** a user exports Markdown containing a valid Mermaid fenced block
- **THEN** the exported single image includes the rendered diagram at the corresponding document position

#### Scenario: Render with compatibility normalization
- **WHEN** a Mermaid fenced block is semantically valid but requires compatibility normalization for the configured runtime parser
- **THEN** preview and export render the normalized diagram output
- **AND** the original Markdown text remains unchanged

### Requirement: Mermaid diagram rendering uses a cohesive theme-aware palette
The system SHALL render Mermaid diagrams with a theme-aware palette and typography baseline that improves readability across supported diagram types while preserving existing Mermaid render behavior.

#### Scenario: Non-mindmap Mermaid diagrams are readable in preview
- **WHEN** a user enters valid Mermaid fenced blocks for supported non-mindmap diagram types
- **THEN** the preview renders diagrams with legible text, clear line and edge contrast, and theme-consistent visual tokens

#### Scenario: Cross-diagram styling remains non-destructive to source and rendering pipeline
- **WHEN** any Mermaid diagram block is rendered
- **THEN** theming is applied through renderer configuration and style layers without mutating user-authored Markdown source
- **AND** Mermaid runtime initialization, normalization, and fallback behavior remain available

### Requirement: Mermaid mindmap rendering includes hierarchy emphasis
The system SHALL render Mermaid `mindmap` diagrams with additional hierarchy emphasis (node contrast, branch clarity, and depth readability) beyond baseline cross-diagram styling.

#### Scenario: Mindmap hierarchy is readable in preview
- **WHEN** a user enters a valid Mermaid `mindmap` fenced block
- **THEN** the preview renders a diagram with visible parent-child hierarchy and legible node text under the currently selected theme

#### Scenario: Mindmap themed appearance is preserved in export
- **WHEN** a user exports Markdown containing a valid Mermaid `mindmap` block
- **THEN** the exported image preserves the selected theme's mindmap hierarchy styling and readability characteristics

### Requirement: Mermaid failures are visible and non-fatal
The system SHALL keep rendering and export available when Mermaid content cannot be rendered, SHALL surface a visible fallback for each failed diagram, and SHALL expose concise error diagnostics to the user while retaining full details in logs.

#### Scenario: Invalid mermaid syntax
- **WHEN** a Mermaid fenced block contains invalid syntax
- **THEN** the preview and export include a visible fallback placeholder indicating the diagram could not be rendered

#### Scenario: Mermaid render timeout
- **WHEN** Mermaid rendering does not complete within the configured timeout
- **THEN** the system proceeds with preview/export using fallback placeholder content for that diagram

#### Scenario: Fallback includes actionable diagnostics
- **WHEN** Mermaid rendering fails due to parser or runtime errors
- **THEN** fallback UI includes concise failure context for the affected diagram
- **AND** renderer logs include detailed diagnostics for troubleshooting
