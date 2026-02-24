## MODIFIED Requirements

### Requirement: User can edit markdown and view rendered preview
The system SHALL provide an iOS interface where users can paste or edit Markdown text and view a rendered preview that reflects current content, including supported table and Mermaid diagram constructs.

#### Scenario: Paste markdown into editor
- **WHEN** a user pastes Markdown content into the input area
- **THEN** the app displays the pasted content and updates the rendered preview accordingly

#### Scenario: Update preview after edits
- **WHEN** a user modifies Markdown content in the editor
- **THEN** the preview re-renders to reflect the latest content without requiring export

#### Scenario: Table markdown is rendered in preview
- **WHEN** a user enters valid Markdown table syntax
- **THEN** the preview renders the table as structured rows and columns instead of plain text

#### Scenario: Mermaid markdown is rendered in preview
- **WHEN** a user enters a valid Mermaid fenced code block
- **THEN** the preview renders a diagram in place of raw Mermaid source text

### Requirement: App exports single long image in supported formats
The system SHALL export rendered Markdown as exactly one image file per export action in `png`, `jpeg`, or `heic` format, preserving rendered table and Mermaid content present in preview.

#### Scenario: Export png as single image
- **WHEN** a user selects `png` and starts export
- **THEN** the app generates one PNG file representing the full rendered document content

#### Scenario: Export jpeg as single image
- **WHEN** a user selects `jpeg` and starts export
- **THEN** the app generates one JPEG file representing the full rendered document content

#### Scenario: Export heic with fallback
- **WHEN** a user selects `heic` and the runtime cannot encode HEIC safely
- **THEN** the app falls back to JPEG export and informs the user about the fallback

#### Scenario: Export includes rendered table content
- **WHEN** a user exports content containing Markdown tables
- **THEN** the generated image includes the rendered table structure and data at the expected positions

#### Scenario: Export includes rendered mermaid diagrams
- **WHEN** a user exports content containing valid Mermaid fenced blocks
- **THEN** the generated image includes the rendered diagrams at the corresponding document positions
