## Why

The current renderer does not consistently support Markdown tables and Mermaid diagrams, so preview and exported images can lose important structure or visual context. Adding first-class support now addresses common documentation use cases and reduces manual post-processing after export.

## What Changes

- Add rendering support for GitHub-style Markdown tables in both live preview and exported image output.
- Add rendering support for fenced Mermaid code blocks, converting them into diagram visuals in both preview and export.
- Define fallback behavior when Mermaid content is invalid or cannot be rendered, so exports remain deterministic and user-visible failures are clear.
- Add coverage criteria for table layout fidelity and Mermaid diagram inclusion in export results.

## Capabilities

### New Capabilities
- `markdown-extended-rendering`: Adds advanced Markdown rendering support for tables and Mermaid diagrams across preview and export.

### Modified Capabilities
- `markdown-image-export-ios`: Expand rendering requirements so preview and exported single-image output include supported table and Mermaid content with defined fallback behavior.

## Impact

- Affected code: Markdown-to-HTML/rendering pipeline, preview web view configuration, export capture pipeline, and related tests.
- Affected dependencies: Potential addition of Markdown table plugin support and Mermaid runtime/script loading strategy.
- UX impact: Users can reliably preview and export richer technical documentation without external conversion steps.
