## ADDED Requirements

### Requirement: Mermaid diagram rendering SHALL use a cohesive theme-aware palette
The system SHALL render Mermaid diagrams with a theme-aware palette and typography baseline that improves readability across supported diagram types while preserving existing Mermaid render behavior.

#### Scenario: Non-mindmap Mermaid diagrams are readable in preview
- **WHEN** a user enters valid Mermaid fenced blocks for supported non-mindmap diagram types
- **THEN** the preview renders diagrams with legible text, clear line/edge contrast, and theme-consistent visual tokens

#### Scenario: Cross-diagram styling remains non-destructive to source and rendering pipeline
- **WHEN** any Mermaid diagram block is rendered
- **THEN** theming is applied through renderer configuration and style layers without mutating user-authored Markdown source
- **AND** Mermaid runtime initialization, normalization, and fallback behavior remain available

### Requirement: Mermaid mindmap rendering SHALL include hierarchy emphasis
The system SHALL render Mermaid `mindmap` diagrams with additional hierarchy emphasis (node contrast, branch clarity, and depth readability) beyond baseline cross-diagram styling.

#### Scenario: Mindmap hierarchy is readable in preview
- **WHEN** a user enters a valid Mermaid `mindmap` fenced block
- **THEN** the preview renders a diagram with visible parent-child hierarchy and legible node text under the currently selected theme

#### Scenario: Mindmap themed appearance is preserved in export
- **WHEN** a user exports Markdown containing a valid Mermaid `mindmap` block
- **THEN** the exported image preserves the selected theme's mindmap hierarchy styling and readability characteristics
