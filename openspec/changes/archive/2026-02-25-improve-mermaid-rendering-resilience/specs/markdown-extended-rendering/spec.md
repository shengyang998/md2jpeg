## MODIFIED Requirements

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
