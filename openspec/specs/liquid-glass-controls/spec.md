## ADDED Requirements

### Requirement: Floating bottom control bar with glass material
The system SHALL display a floating bottom control bar containing three elements: a theme button (left), a Raw/Preview segmented toggle (center), and an export button (right). The bar SHALL use translucent glass material styling.

#### Scenario: Bottom bar is always visible
- **WHEN** the app is in any mode (raw or preview)
- **THEN** the floating bottom control bar is visible with theme, toggle, and export controls

#### Scenario: Bottom bar uses glass material
- **WHEN** the bottom bar is rendered
- **THEN** it uses a translucent material background (`.ultraThinMaterial`) with rounded shape so underlying content is partially visible through it

### Requirement: Contextual top-right action buttons in raw mode
The system SHALL display floating paste and clear buttons at the top-right corner of the screen only when the app is in raw mode. The buttons SHALL fade in/out with animation when the mode changes.

#### Scenario: Buttons appear in raw mode
- **WHEN** the user is in raw mode
- **THEN** paste and clear buttons are visible at the top-right corner with glass material styling

#### Scenario: Buttons hidden in preview mode
- **WHEN** the user switches to preview mode
- **THEN** the paste and clear buttons fade out and are not visible

#### Scenario: Paste button pastes clipboard content
- **WHEN** the user taps the paste button in raw mode
- **THEN** the clipboard text content replaces the current markdown text in the editor

### Requirement: Clear button uses iOS Photos-style confirmation
The system SHALL present a confirmation dialog when the user taps the clear button, following the iOS Photos album delete pattern.

#### Scenario: Clear with confirmation
- **WHEN** the user taps the clear (trash) button
- **THEN** a confirmation dialog slides up from the bottom with a destructive "Delete All Content" action and a "Cancel" action

#### Scenario: Confirm clear deletes content
- **WHEN** the user taps "Delete All Content" in the confirmation dialog
- **THEN** the markdown text is cleared to empty

#### Scenario: Cancel clear preserves content
- **WHEN** the user taps "Cancel" in the confirmation dialog
- **THEN** the markdown text is unchanged

#### Scenario: Clear button disabled when empty
- **WHEN** the markdown text is already empty
- **THEN** the clear button is visually disabled and non-interactive

### Requirement: Bottom bar moves above keyboard
The system SHALL position the floating bottom bar above the software keyboard when the keyboard is visible in raw mode.

#### Scenario: Keyboard appears in raw mode
- **WHEN** the user taps into the editor and the keyboard appears
- **THEN** the floating bottom bar animates upward to sit above the keyboard

#### Scenario: Keyboard dismisses
- **WHEN** the keyboard is dismissed
- **THEN** the floating bottom bar animates back to its default bottom position
