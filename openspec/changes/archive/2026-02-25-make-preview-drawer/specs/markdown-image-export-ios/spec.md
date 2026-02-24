## MODIFIED Requirements

### Requirement: User can edit markdown and view rendered preview
The system SHALL provide an iOS interface where users can paste or edit Markdown text and view a rendered preview in a bottom drawer that supports full-screen expansion, while preserving support for table and Mermaid diagram constructs.

#### Scenario: Paste markdown into editor
- **WHEN** a user pastes Markdown content into the input area
- **THEN** the app displays the pasted content and updates the rendered preview content in the drawer accordingly

#### Scenario: Update preview after edits
- **WHEN** a user modifies Markdown content in the editor
- **THEN** the preview re-renders to reflect the latest content without requiring export

#### Scenario: Table markdown is rendered in preview
- **WHEN** a user enters valid Markdown table syntax
- **THEN** the preview renders the table as structured rows and columns instead of plain text

#### Scenario: Mermaid markdown is rendered in preview
- **WHEN** a user enters a valid Mermaid fenced code block
- **THEN** the preview renders a diagram in place of raw Mermaid source text

#### Scenario: Expand preview drawer to full-screen mode
- **WHEN** the user drags the preview drawer upward to the full-screen threshold
- **THEN** the rendered preview occupies full screen and markdown editing is temporarily hidden

#### Scenario: Collapse preview drawer to resume full-screen editing
- **WHEN** the user drags or scrolls the full-screen preview drawer downward to the collapse threshold
- **THEN** the preview drawer hides and the markdown editor returns to full-screen editing mode
