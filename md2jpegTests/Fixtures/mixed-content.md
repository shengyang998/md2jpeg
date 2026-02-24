# Engineering Notes

| Component | Status | Owner |
| --- | --- | --- |
| Preview | Ready | iOS |
| Export | In Progress | Core |

```mermaid
flowchart LR
  A[Markdown Input] --> B[HTML Render]
  B --> C[Preview]
  B --> D[Export]
```

This fixture mixes plain text, table content, and a Mermaid diagram.
