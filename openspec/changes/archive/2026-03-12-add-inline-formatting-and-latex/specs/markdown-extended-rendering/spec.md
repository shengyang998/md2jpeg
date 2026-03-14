## ADDED Requirements

### Requirement: Renderer supports italic text with single asterisk
The system SHALL parse `*text*` delimiters in inline text and render the enclosed content as italic (`<em>`) in preview and export contexts.

#### Scenario: Render italic text in preview
- **WHEN** a user enters text containing `*italic text*`
- **THEN** the preview renders "italic text" in italic style

#### Scenario: Italic text preserved in export
- **WHEN** a user exports markdown containing `*italic text*`
- **THEN** the exported image includes the text rendered in italic

### Requirement: Renderer supports bold-italic text with triple asterisk
The system SHALL parse `***text***` delimiters in inline text and render the enclosed content as bold-italic (`<strong><em>`) in preview and export contexts.

#### Scenario: Render bold-italic text in preview
- **WHEN** a user enters text containing `***bold italic***`
- **THEN** the preview renders "bold italic" in both bold and italic style

#### Scenario: Bold-italic text preserved in export
- **WHEN** a user exports markdown containing `***bold italic***`
- **THEN** the exported image includes the text rendered in bold-italic

### Requirement: Inline formatting handles mixed emphasis correctly
The system SHALL process `***`, `**`, and `*` delimiters in longest-first order to avoid ambiguous matches when multiple emphasis levels appear in the same line.

#### Scenario: Mixed bold and italic on same line
- **WHEN** a user enters `**bold** and *italic*` on the same line
- **THEN** the preview renders "bold" in bold and "italic" in italic, with "and" unstyled

#### Scenario: Bold-italic does not conflict with bold or italic
- **WHEN** a user enters `***all*** then **bold** then *italic*`
- **THEN** the preview renders each segment with its correct emphasis level
