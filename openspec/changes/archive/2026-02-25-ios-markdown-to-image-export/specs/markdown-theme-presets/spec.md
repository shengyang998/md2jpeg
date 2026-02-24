## ADDED Requirements

### Requirement: App includes bundled markdown theme presets
The system SHALL include at least three bundled visual themes for Markdown rendering.

#### Scenario: Theme presets available at startup
- **WHEN** the user opens the app
- **THEN** the UI presents a theme selector with at least three built-in options

### Requirement: Theme selection updates preview immediately
The system SHALL apply the selected theme to the preview without requiring export.

#### Scenario: Switch active theme
- **WHEN** a user selects a different theme preset
- **THEN** the preview updates to the selected theme in the current session

### Requirement: Export output matches selected theme
The system SHALL apply the currently selected theme to exported images.

#### Scenario: Export after theme switch
- **WHEN** a user changes the theme and exports an image
- **THEN** the generated image reflects the selected theme styles instead of the previous theme
