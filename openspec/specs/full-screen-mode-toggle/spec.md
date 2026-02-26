## ADDED Requirements

### Requirement: App presents a full-screen raw/preview mode toggle
The system SHALL display content in a single full-screen area that operates in one of two modes: raw (editable markdown text) or preview (rendered HTML). A segmented toggle control SHALL switch between modes.

#### Scenario: App launches in last-used mode
- **WHEN** the user opens the app
- **THEN** the content area displays in the mode the user last used (raw or preview), defaulting to raw on first launch

#### Scenario: User switches from raw to preview
- **WHEN** the user taps the "Preview" segment of the toggle while in raw mode
- **THEN** the raw editor transitions out and the rendered preview transitions in via a blur morph animation

#### Scenario: User switches from preview to raw
- **WHEN** the user taps the "Raw" segment of the toggle while in preview mode
- **THEN** the rendered preview transitions out and the raw editor transitions in via a blur morph animation

#### Scenario: Mode preference is persisted
- **WHEN** the user switches modes and later closes and reopens the app
- **THEN** the app restores the last-used mode

### Requirement: Blur morph transition animates mode switches
The system SHALL animate mode transitions using a blur-based morph: the outgoing view blurs and fades out while the incoming view sharpens and fades in, creating a frosted-glass crossfade effect.

#### Scenario: Transition visual continuity
- **WHEN** a mode switch is triggered
- **THEN** the transition completes within approximately 0.4 seconds using spring animation and the content area never appears empty during the transition

#### Scenario: Preview content is ready on switch
- **WHEN** the user switches to preview mode after editing markdown
- **THEN** the preview shows the latest rendered content immediately (no loading spinner) because the WKWebView is kept loaded in background

### Requirement: Text editing is only available in raw mode
The system SHALL allow text editing only in raw mode. In preview mode, the content is read-only.

#### Scenario: Editing in raw mode
- **WHEN** the app is in raw mode
- **THEN** the user can tap into the text area and type or paste markdown content

#### Scenario: No editing in preview mode
- **WHEN** the app is in preview mode
- **THEN** no text input is possible and the rendered content is read-only
