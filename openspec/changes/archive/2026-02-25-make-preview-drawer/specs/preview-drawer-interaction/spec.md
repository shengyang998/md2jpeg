## ADDED Requirements

### Requirement: Preview is presented as a bottom drawer
The system SHALL present rendered markdown preview inside a bottom-anchored drawer that can be expanded for full-screen preview and hidden to restore full-screen editing.

#### Scenario: Drawer starts hidden for editing focus
- **WHEN** the editor screen is shown
- **THEN** the preview drawer is hidden at the bottom and the markdown editor occupies the full available editing area

#### Scenario: User expands preview drawer upward
- **WHEN** the user drags the drawer upward past the expansion threshold
- **THEN** the preview drawer transitions to an expanded full-screen preview state

#### Scenario: User collapses preview drawer downward
- **WHEN** the user drags or scrolls the expanded drawer downward past the collapse threshold
- **THEN** the preview drawer hides at the bottom and full-screen editing is restored

### Requirement: Drawer transitions preserve rendered content continuity
The system SHALL preserve the current rendered preview content while transitioning drawer states so users do not lose context.

#### Scenario: Expanding drawer keeps latest rendered preview
- **WHEN** the user expands the preview drawer after editing markdown
- **THEN** the expanded preview shows the latest rendered content without requiring a manual refresh

#### Scenario: Re-opening drawer preserves last preview position
- **WHEN** the user hides the preview drawer and then re-opens it without changing markdown
- **THEN** the preview reappears with preserved rendered state and no visual reset artifacts
