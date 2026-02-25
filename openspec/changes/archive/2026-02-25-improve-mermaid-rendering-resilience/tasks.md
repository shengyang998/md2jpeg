## 1. Mermaid runtime determinism and render pipeline

- [ ] 1.1 Pin Mermaid script reference in `HTMLTemplateBuilder` to a concrete validated version and document upgrade policy.
- [ ] 1.2 Add a Mermaid source normalization function that runs in-memory before `mermaid.render` without mutating stored Markdown.
- [ ] 1.3 Wire normalization into both preview and export render paths to keep behavior consistent across visible and background web views.

## 2. Failure diagnostics and non-fatal fallback behavior

- [ ] 2.1 Extend Mermaid render error handling to capture parser/runtime error details per diagram block.
- [ ] 2.2 Update fallback UI text to include concise actionable diagnostics while preserving raw Mermaid source visibility.
- [ ] 2.3 Add structured logging for full Mermaid error payloads to support troubleshooting without blocking render/export.

## 3. Verification and regression coverage

- [ ] 3.1 Add unit tests for normalization behavior and guarantee that original Markdown content remains unchanged.
- [ ] 3.2 Add renderer/export tests validating pinned runtime usage and readiness behavior when diagrams fail or time out.
- [ ] 3.3 Add fixture-based compatibility cases for Mermaid diagrams that previously failed in WebKit and assert fallback diagnostics quality.
