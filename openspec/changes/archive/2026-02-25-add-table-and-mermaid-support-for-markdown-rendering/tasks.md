## 1. Rendering Pipeline Foundation

- [x] 1.1 Identify and update the Markdown parser configuration to enable GitHub-style table parsing in the shared render path.
- [x] 1.2 Add or configure Mermaid runtime integration in the web rendering environment used by preview and export.
- [x] 1.3 Implement fenced-block detection and Mermaid render invocation for `mermaid` code blocks.
- [x] 1.4 Implement a bounded render-complete signal so export waits for Mermaid rendering or timeout before capture.

## 2. Fallback and Reliability Behavior

- [x] 2.1 Implement non-fatal Mermaid failure handling for invalid syntax, script-load failure, and render timeout cases.
- [x] 2.2 Add visible placeholder/error output for failed Mermaid diagrams that appears in both preview and export.
- [x] 2.3 Ensure fallback behavior does not break existing single-image export flow, including format selection and HEIC fallback.
- [x] 2.4 Verify existing memory-safety safeguards still apply when documents include large tables or diagrams.

## 3. Export Fidelity and Consistency

- [x] 3.1 Ensure rendered table layout is preserved in exported images with no missing rows/columns.
- [x] 3.2 Ensure rendered Mermaid diagrams are preserved at correct document positions in exported images.
- [ ] 3.3 Validate preview/export parity for mixed content documents (text, tables, valid Mermaid, invalid Mermaid).
- [x] 3.4 Add or update test fixtures representing realistic technical-doc inputs for table and Mermaid scenarios.

## 4. Verification and QA

- [x] 4.1 Add/extend automated tests for table rendering in preview and export.
- [x] 4.2 Add/extend automated tests for Mermaid success and fallback scenarios in preview and export.
- [ ] 4.3 Run regression tests for existing markdown export requirements (single-image output, completeness, and safe failure behavior).
- [x] 4.4 Update QA checklist or validation notes to include manual verification cases for tables and Mermaid diagrams.
