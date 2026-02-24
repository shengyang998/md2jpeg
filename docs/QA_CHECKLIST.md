# Manual QA Checklist

## Devices / OS
- iPhone simulator (latest iOS)
- iPhone simulator (minimum supported iOS)

## Preview and Editing
- Paste markdown into editor and confirm preview updates.
- Type additional markdown and confirm preview updates live.
- Confirm preview error banner appears if web content fails.

## Tables and Mermaid
- Paste markdown table syntax and confirm preview renders a visible table with header/body cells.
- Export markdown containing a table and confirm no rows or columns are missing in the saved image.
- Paste valid Mermaid fenced block and confirm preview renders a diagram (not raw source text).
- Paste Mermaid `mindmap` syntax and confirm preview renders a mindmap diagram.
- Switch app theme (`Classic`, `Paper`, `Dark`) and confirm Mermaid/mindmap styling follows the selected theme.
- Export markdown containing valid Mermaid and confirm diagram appears in the saved image at the expected position.
- Paste invalid Mermaid fenced block and confirm preview/export shows a visible fallback message with diagram source text.

## Themes
- Switch among `Classic`, `Paper`, and `Dark`.
- Confirm preview style changes instantly.
- Export after switching theme and verify exported image matches selected theme.

## Export Formats
- Export as PNG and confirm image saves to system Photos album.
- Export as JPEG and confirm image saves to system Photos album.
- Export as HEIC:
  - If supported, confirm HEIC file exported.
  - If unsupported, confirm fallback message and JPEG output in Photos.

## Long Document Guardrails
- Paste long markdown that remains within safe budget and confirm export succeeds.
- Paste very large markdown that exceeds budget and confirm graceful error message.
- Export a long document multiple times and confirm first lines are always present.
- Compare preview top section to exported image top section to ensure no clipping.

## Regression
- Confirm exactly one image file is produced per export action.
- Confirm no page-splitting option is shown in v1 UI.
