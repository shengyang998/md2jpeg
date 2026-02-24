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
The system SHALL detect fenced code blocks marked as `mermaid` and render them as diagram visuals in preview and export rendering contexts.

#### Scenario: Render mermaid flowchart in preview
- **WHEN** a user enters a valid Mermaid fenced block
- **THEN** the preview shows a rendered diagram instead of raw Mermaid source text

#### Scenario: Preserve rendered mermaid diagram in exported image
- **WHEN** a user exports Markdown containing a valid Mermaid fenced block
- **THEN** the exported single image includes the rendered diagram at the corresponding document position

### Requirement: Mermaid failures are visible and non-fatal
The system SHALL keep rendering and export available when Mermaid content cannot be rendered, and SHALL surface a visible fallback for each failed diagram.

#### Scenario: Invalid mermaid syntax
- **WHEN** a Mermaid fenced block contains invalid syntax
- **THEN** the preview and export include a visible fallback placeholder indicating the diagram could not be rendered

#### Scenario: Mermaid render timeout
- **WHEN** Mermaid rendering does not complete within the configured timeout
- **THEN** the system proceeds with preview/export using fallback placeholder content for that diagram
