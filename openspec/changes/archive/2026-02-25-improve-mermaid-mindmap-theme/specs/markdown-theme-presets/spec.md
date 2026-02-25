## MODIFIED Requirements

### Requirement: Theme selection updates preview immediately
The system SHALL apply the selected theme to the preview without requiring export, including themed Mermaid styling for diagrams present in the current document.

#### Scenario: Switch active theme
- **WHEN** a user selects a different theme preset
- **THEN** the preview updates to the selected theme in the current session
- **AND** rendered Mermaid diagrams refresh to reflect that preset's visual tokens across mindmap and supported non-mindmap types

### Requirement: Export output matches selected theme
The system SHALL apply the currently selected theme to exported images, including Mermaid styling so exported diagrams match preview theme identity.

#### Scenario: Export after theme switch
- **WHEN** a user changes the theme and exports an image
- **THEN** the generated image reflects the selected theme styles instead of the previous theme
- **AND** Mermaid diagrams in the export use the same theme-specific styling as preview
