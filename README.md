# md2jpeg

An iOS app that converts Markdown into shareable images. Write or paste Markdown, preview it live, and export as PNG, JPEG, or HEIC — all in one step.

## Features

- **Live preview** — Edits appear instantly in a scrollable WebView preview
- **Mermaid diagrams** — Fenced ` ```mermaid ` blocks render as diagrams with theme-aware styling
- **GitHub-style tables** — Full table support with headers and alignment
- **Three themes** — Classic, Paper, and Dark, applied to both preview and export
- **Multiple export formats** — PNG (lossless), JPEG, or HEIC
- **Long document support** — Tiled snapshotting with a 40M-pixel budget keeps memory usage safe
- **Save to Photos** — Exported images are saved directly to the system photo library

## Requirements

- Xcode 26+
- iOS 26.2+ / macOS 26.2+
- No external Swift package dependencies

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/soleilyu/md2jpeg.git
   cd md2jpeg
   ```
2. Open `md2jpeg.xcodeproj` in Xcode.
3. Select a simulator or device target and run.

## How It Works

```
Markdown text
  → MarkdownHTMLRenderer (parse to HTML)
  → HTMLTemplateBuilder (wrap with theme CSS + Mermaid.js)
  → WKWebView (render & preview)
  → WebViewSnapshotter (tiled capture)
  → ImageFormatEncoder (PNG / JPEG / HEIC)
  → PhotoLibrarySaver (save to library)
```

### Markdown Rendering

A custom parser (`MarkdownHTMLRenderer`) converts Markdown to HTML, supporting headings, lists, bold, inline code, code blocks, tables, horizontal rules, and Mermaid diagram blocks. The HTML is wrapped by `HTMLTemplateBuilder` with the selected theme CSS and Mermaid.js initialization.

### Export Pipeline

`ImageExportService` orchestrates the export. `WebViewSnapshotter` captures the rendered content in tiles (2048 pt height each) to avoid memory pressure on long documents, composites them into a single image, and hands off to `ImageFormatEncoder` for format-specific encoding. The result is saved to the Photos library via `PhotoLibrarySaver`.

## Project Structure

```
md2jpeg/
├── App/                        # Entry point and app state
├── Domain/                     # Models (themes, export limits)
├── Services/
│   ├── MarkdownHTMLRenderer    # Markdown → HTML parser
│   ├── HTMLTemplateBuilder     # HTML document assembly
│   └── Export/                 # Snapshot, encode, save pipeline
├── Views/                      # SwiftUI views
└── Resources/Themes/           # CSS theme files
```

## Testing

Run tests from Xcode or the command line:

```bash
xcodebuild test -project md2jpeg.xcodeproj -scheme md2jpeg -destination 'platform=iOS Simulator,name=iPhone 16'
```

Unit tests cover Markdown parsing, export limits, image encoding, tiling logic, theme presets, and drawer behavior. See [`docs/QA_CHECKLIST.md`](docs/QA_CHECKLIST.md) for manual testing scenarios.

## Privacy Policy

See [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md).

## License

MIT
