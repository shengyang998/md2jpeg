## ADDED Requirements

### Requirement: Export format selection via confirmation dialog
The system SHALL present a confirmation dialog with format options when the user taps the export button, instead of a persistent format picker.

#### Scenario: User taps export button
- **WHEN** the user taps the export button in the floating bottom bar
- **THEN** a confirmation dialog appears listing "JPEG", "PNG", and "HEIC" as actions, plus "Cancel"

#### Scenario: User selects a format
- **WHEN** the user taps a format option in the dialog
- **THEN** the export begins immediately in the selected format

#### Scenario: User cancels export
- **WHEN** the user taps "Cancel" in the format dialog
- **THEN** no export is triggered and the app returns to its previous state

### Requirement: Full-screen circular progress during export
The system SHALL display a full-screen overlay with a circular progress indicator during the export process, replacing the previous linear progress bar.

#### Scenario: Export starts
- **WHEN** the user selects a format and export begins
- **THEN** a full-screen translucent overlay appears with a circular progress indicator showing percentage completion

#### Scenario: Export progresses
- **WHEN** the export pipeline reports progress updates
- **THEN** the circular progress indicator and percentage label update in real time

#### Scenario: Export completes successfully
- **WHEN** the export finishes and the image is saved to the photo library
- **THEN** the progress overlay fades out and a brief success indication is shown

#### Scenario: Export fails
- **WHEN** the export encounters an error
- **THEN** the progress overlay is dismissed and an error alert is presented

#### Scenario: Interaction blocked during export
- **WHEN** the export progress overlay is visible
- **THEN** all other controls (toggle, paste, clear, theme, export) are non-interactive
