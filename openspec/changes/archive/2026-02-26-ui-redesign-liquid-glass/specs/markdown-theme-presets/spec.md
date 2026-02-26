## MODIFIED Requirements

### Requirement: App includes bundled markdown theme presets
The system SHALL include at least three bundled visual themes for Markdown rendering.

#### Scenario: Theme presets available via popover
- **WHEN** the user taps the theme button in the floating bottom bar
- **THEN** a popover appears presenting at least three built-in theme options as a vertical list

### Requirement: Theme selection updates preview immediately
The system SHALL apply the selected theme to the preview without requiring export, including themed Mermaid styling for diagrams present in the current document.

#### Scenario: Switch active theme via popover
- **WHEN** a user selects a different theme preset from the theme popover
- **THEN** the popover dismisses, the preview updates to the selected theme in the current session
- **AND** rendered Mermaid diagrams refresh to reflect that preset's visual tokens across mindmap and supported non-mindmap types

### Requirement: Export output matches selected theme
The system SHALL apply the currently selected theme to exported images, including Mermaid styling so exported diagrams match preview theme identity.

#### Scenario: Export after theme switch
- **WHEN** a user changes the theme via the popover and exports an image
- **THEN** the generated image reflects the selected theme styles instead of the previous theme
- **AND** Mermaid diagrams in the export use the same theme-specific styling as preview
