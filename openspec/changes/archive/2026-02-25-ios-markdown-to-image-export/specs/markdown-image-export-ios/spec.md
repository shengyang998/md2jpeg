## ADDED Requirements

### Requirement: User can edit markdown and view rendered preview
The system SHALL provide an iOS interface where users can paste or edit Markdown text and view a rendered preview that reflects current content.

#### Scenario: Paste markdown into editor
- **WHEN** a user pastes Markdown content into the input area
- **THEN** the app displays the pasted content and updates the rendered preview accordingly

#### Scenario: Update preview after edits
- **WHEN** a user modifies Markdown content in the editor
- **THEN** the preview re-renders to reflect the latest content without requiring export

### Requirement: App exports single long image in supported formats
The system SHALL export rendered Markdown as exactly one image file per export action in `png`, `jpeg`, or `heic` format.

#### Scenario: Export png as single image
- **WHEN** a user selects `png` and starts export
- **THEN** the app generates one PNG file representing the full rendered document content

#### Scenario: Export jpeg as single image
- **WHEN** a user selects `jpeg` and starts export
- **THEN** the app generates one JPEG file representing the full rendered document content

#### Scenario: Export heic with fallback
- **WHEN** a user selects `heic` and the runtime cannot encode HEIC safely
- **THEN** the app falls back to JPEG export and informs the user about the fallback

### Requirement: Export pipeline is memory-bounded for long content
The system SHALL implement export safeguards to reduce out-of-memory risk when exporting very tall documents.

#### Scenario: Render within safe resource budget
- **WHEN** rendered dimensions are within configured memory thresholds
- **THEN** the app completes export using bounded memory behavior and produces a single output image

#### Scenario: Render exceeds safe resource budget
- **WHEN** estimated export dimensions exceed configured memory thresholds
- **THEN** the app aborts export before crash conditions and shows a clear failure message with corrective guidance

### Requirement: Exported image completeness is preserved
The system SHALL ensure exported single-image output includes complete rendered content from the first line to the last line.

#### Scenario: First lines are present in export
- **WHEN** a user exports markdown content with headings or text at the top of the document
- **THEN** the exported image includes the first lines shown in preview without clipping

#### Scenario: Multi-tile export has no gaps
- **WHEN** export processes a long document using tiled capture
- **THEN** tiles compose continuously without missing sections between tile boundaries

#### Scenario: Incomplete capture is rejected
- **WHEN** the exporter detects unstable layout or incomplete tile/composition coverage
- **THEN** the export is rejected with a clear retryable error instead of saving a partial image

### Requirement: App saves export to photo library
The system SHALL save successfully exported images directly to the system photo library.

#### Scenario: Save generated image
- **WHEN** export succeeds
- **THEN** the app saves the generated image into the system album and confirms success
