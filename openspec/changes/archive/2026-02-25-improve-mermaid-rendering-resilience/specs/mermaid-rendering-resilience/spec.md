## ADDED Requirements

### Requirement: Mermaid source SHALL remain user-authored while allowing runtime compatibility normalization
The system SHALL preserve user-authored Markdown content unchanged at rest and during editing, and SHALL apply Mermaid compatibility normalization only in-memory at render time.

#### Scenario: Render-time normalization without source mutation
- **WHEN** a document contains Mermaid source that needs compatibility normalization for the current runtime
- **THEN** the renderer applies normalization before Mermaid parsing
- **AND** the original Markdown source remains unchanged in editor state and persisted content

### Requirement: Mermaid runtime version SHALL be deterministic
The system SHALL render Mermaid using a pinned concrete runtime version rather than a floating major tag to avoid untracked parser behavior drift.

#### Scenario: Pinned runtime reference is used
- **WHEN** preview or export initializes Mermaid runtime
- **THEN** the runtime loader references a specific Mermaid version string
- **AND** rendering behavior does not depend on implicit CDN major-version updates

### Requirement: Mermaid failures SHALL include actionable diagnostics
The system SHALL expose Mermaid failure diagnostics in a user-visible fallback and in application logs while keeping rendering non-fatal.

#### Scenario: Parser error surfaced with fallback
- **WHEN** Mermaid parsing fails for a diagram block
- **THEN** the preview/export displays a fallback message with concise error context
- **AND** the raw Mermaid source remains visible for recovery
- **AND** detailed diagnostics are recorded in logs for troubleshooting
