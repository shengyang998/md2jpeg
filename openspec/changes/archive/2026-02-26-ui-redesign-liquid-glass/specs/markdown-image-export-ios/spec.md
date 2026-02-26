## MODIFIED Requirements

### Requirement: User can edit markdown and view rendered preview
The system SHALL provide an iOS interface where users can paste or edit Markdown text in a full-screen raw mode and view a rendered preview in a full-screen preview mode toggled via a segmented control, while preserving support for table and Mermaid diagram constructs.

#### Scenario: Paste markdown into editor
- **WHEN** a user pastes Markdown content into the input area (via keyboard or paste button) while in raw mode
- **THEN** the app displays the pasted content and updates the rendered preview content in background accordingly

#### Scenario: Update preview after edits
- **WHEN** a user modifies Markdown content in the raw editor
- **THEN** the preview re-renders in background to reflect the latest content without requiring export

#### Scenario: Table markdown is rendered in preview
- **WHEN** a user enters valid Markdown table syntax and switches to preview mode
- **THEN** the preview renders the table as structured rows and columns instead of plain text

#### Scenario: Mermaid markdown is rendered in preview
- **WHEN** a user enters a valid Mermaid fenced code block and switches to preview mode
- **THEN** the preview renders a diagram in place of raw Mermaid source text

#### Scenario: Switch to preview mode to view rendered content
- **WHEN** the user taps the "Preview" segment of the mode toggle
- **THEN** the rendered preview occupies full screen with a blur morph transition

#### Scenario: Switch to raw mode to resume editing
- **WHEN** the user taps the "Raw" segment of the mode toggle
- **THEN** the markdown editor returns to full screen with a blur morph transition

### Requirement: App exports single long image in supported formats
The system SHALL export rendered Markdown as exactly one image file per export action in `png`, `jpeg`, or `heic` format, with format selected via a confirmation dialog triggered by the export button in the floating bottom bar.

#### Scenario: Export png as single image
- **WHEN** a user selects `PNG` from the export confirmation dialog
- **THEN** the app generates one PNG file representing the full rendered document content

#### Scenario: Export jpeg as single image
- **WHEN** a user selects `JPEG` from the export confirmation dialog
- **THEN** the app generates one JPEG file representing the full rendered document content

#### Scenario: Export heic with fallback
- **WHEN** a user selects `HEIC` from the export confirmation dialog and the runtime cannot encode HEIC safely
- **THEN** the app falls back to JPEG export and informs the user about the fallback

#### Scenario: Export includes rendered table content
- **WHEN** a user exports content containing Markdown tables
- **THEN** the generated image includes the rendered table structure and data at the expected positions

#### Scenario: Export includes rendered mermaid diagrams
- **WHEN** a user exports content containing valid Mermaid fenced blocks
- **THEN** the generated image includes the rendered diagrams at the corresponding document positions
