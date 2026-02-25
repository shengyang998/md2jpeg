#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: bash scripts/preview-mermaid.sh --file <markdown-or-mermaid-file> [--theme classic|paper|dark] [--no-open]"
  exit 1
}

theme="dark"
input_file=""
open_after_generate="1"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --theme)
      theme="${2:-}"
      shift 2
      ;;
    --file)
      input_file="${2:-}"
      shift 2
      ;;
    --no-open)
      open_after_generate="0"
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      ;;
  esac
done

if [[ -z "$input_file" ]]; then
  echo "Error: --file is required."
  usage
fi

if [[ ! -f "$input_file" ]]; then
  echo "Error: file not found: $input_file"
  exit 1
fi

if [[ "$theme" != "classic" && "$theme" != "paper" && "$theme" != "dark" ]]; then
  echo "Error: unsupported theme '$theme'. Use classic, paper, or dark."
  exit 1
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
css_path="$repo_root/md2jpeg/Resources/Themes/theme-$theme.css"
if [[ ! -f "$css_path" ]]; then
  echo "Error: theme css not found: $css_path"
  exit 1
fi

tmp_dir="$script_dir/.tmp"
mkdir -p "$tmp_dir"
tmp_base="$(mktemp "$tmp_dir/md2jpeg-mermaid-preview.XXXXXX")"
output_html="${tmp_base}.html"
mv "$tmp_base" "$output_html"

python3 - "$input_file" "$css_path" "$theme" "$output_html" <<'PY'
import html
import pathlib
import re
import sys

input_path = pathlib.Path(sys.argv[1])
css_path = pathlib.Path(sys.argv[2])
theme = sys.argv[3]
output_path = pathlib.Path(sys.argv[4])

raw = input_path.read_text(encoding="utf-8")
css = css_path.read_text(encoding="utf-8")

fence_pattern = re.compile(r"```mermaid[ \t]*\n(.*?)```", re.DOTALL | re.IGNORECASE)
blocks = [m.group(1).rstrip("\n") for m in fence_pattern.finditer(raw)]
if not blocks:
  blocks = [raw.rstrip("\n")]

containers = []
for block in blocks:
  escaped = html.escape(block, quote=False)
  containers.append(
      '<div class="mermaid-container" data-mermaid-container="true">\n'
      f'  <pre class="mermaid">{escaped}</pre>\n'
      '  <div class="mermaid-error" hidden>Unable to render Mermaid diagram.</div>\n'
      '  <div class="mermaid-error-detail" hidden></div>\n'
      f'  <pre class="mermaid-source-fallback" hidden>{escaped}</pre>\n'
      '</div>'
  )

theme_configs = {
  "classic": '{"theme":"base","startOnLoad":false,"securityLevel":"strict","themeVariables":{"fontFamily":"-apple-system, BlinkMacSystemFont, \\"Segoe UI\\", sans-serif","fontSize":"14px","primaryColor":"#eef2ff","primaryTextColor":"#1e293b","primaryBorderColor":"#a5b4fc","lineColor":"#6366f1","secondaryColor":"#f1f5f9","tertiaryColor":"#e0e7ff","background":"#ffffff","mainBkg":"#eef2ff","textColor":"#1e293b","noteBkgColor":"#e0e7ff","noteTextColor":"#3730a3","noteBorderColor":"#a5b4fc","cScale0":"#e0e7ff","cScaleLabel0":"#312e81"}}',
  "paper": '{"theme":"base","startOnLoad":false,"securityLevel":"strict","themeVariables":{"fontFamily":"Georgia, \\"Times New Roman\\", serif","fontSize":"14px","primaryColor":"#f5ede2","primaryTextColor":"#1c1917","primaryBorderColor":"#d6b98e","lineColor":"#92400e","secondaryColor":"#faf7f2","tertiaryColor":"#ece0cf","background":"#faf7f2","mainBkg":"#f5ede2","textColor":"#1c1917","noteBkgColor":"#f5ede2","noteTextColor":"#78350f","noteBorderColor":"#d6b98e","cScale0":"#ede0cc","cScaleLabel0":"#451a03"}}',
  "dark": '{"theme":"base","startOnLoad":false,"securityLevel":"strict","themeVariables":{"fontFamily":"-apple-system, BlinkMacSystemFont, \\"Segoe UI\\", sans-serif","fontSize":"14px","darkMode":true,"primaryColor":"#1e293b","primaryTextColor":"#e2e8f0","primaryBorderColor":"#475569","lineColor":"#60a5fa","secondaryColor":"#0f172a","tertiaryColor":"#1e293b","background":"#0f172a","mainBkg":"#1e293b","textColor":"#e2e8f0","noteBkgColor":"#1e293b","noteTextColor":"#94a3b8","noteBorderColor":"#475569","cScale0":"#243352","cScaleLabel0":"#ffffff"}}'
}
config = theme_configs[theme]

html_doc = f"""<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10.9.5/dist/mermaid.min.js"></script>
  <style>
{css}
  </style>
</head>
<body data-md2jpeg-ready="false">
  <article class="markdown-root">
{chr(10).join(containers)}
  </article>
  <script>
  (function () {{
    function markReady() {{
      document.body.setAttribute("data-md2jpeg-ready", "true");
    }}

    function showFallback(container, detailText) {{
      if (!container) {{ return; }}
      container.classList.add("mermaid-failed");
      var errorNode = container.querySelector(".mermaid-error");
      var detailNode = container.querySelector(".mermaid-error-detail");
      var sourceNode = container.querySelector(".mermaid-source-fallback");
      if (errorNode) {{ errorNode.hidden = false; }}
      if (detailNode) {{
        detailNode.hidden = false;
        detailNode.textContent = detailText || "No diagnostics available.";
      }}
      if (sourceNode) {{ sourceNode.hidden = false; }}
    }}

    function sanitizeMermaidSVG(root) {{
      if (!root || !root.querySelectorAll) {{ return; }}
      var lineNodes = root.querySelectorAll('line[class*="node-line"]');
      lineNodes.forEach(function (node) {{
        node.remove();
      }});
      var backgroundRects = root.querySelectorAll("svg > rect.background, svg > rect[id*='background']");
      backgroundRects.forEach(function (rect) {{
        rect.remove();
      }});
      var svgNs = "http://www.w3.org/2000/svg";
      var mindmapNodePaths = root.querySelectorAll(".mindmap-node path.node-bkg.node-no-border");
      mindmapNodePaths.forEach(function (pathNode) {{
        try {{
          var bbox = pathNode.getBBox();
          if (!bbox || !isFinite(bbox.width) || !isFinite(bbox.height) || bbox.width <= 0 || bbox.height <= 0) {{
            return;
          }}
          var rect = document.createElementNS(svgNs, "rect");
          rect.setAttribute("x", String(bbox.x));
          rect.setAttribute("y", String(bbox.y));
          rect.setAttribute("width", String(bbox.width));
          rect.setAttribute("height", String(bbox.height));
          rect.setAttribute("rx", "8");
          rect.setAttribute("ry", "8");
          ["class", "style", "fill", "stroke", "stroke-width", "opacity", "filter"].forEach(function (name) {{
            var value = pathNode.getAttribute(name);
            if (value) {{ rect.setAttribute(name, value); }}
          }});
          pathNode.parentNode.insertBefore(rect, pathNode);
          pathNode.remove();
        }} catch (_) {{}}
      }});
    }}

    var blocks = Array.prototype.slice.call(document.querySelectorAll("pre.mermaid"));
    if (typeof mermaid === "undefined") {{
      blocks.forEach(function (block) {{
        showFallback(block.closest(".mermaid-container"), "Mermaid runtime failed to load.");
      }});
      markReady();
      return;
    }}

    mermaid.initialize({config});
    Promise.all(blocks.map(function (block, index) {{
      var source = block.textContent || "";
      return mermaid.render("md2jpeg-mermaid-" + index, source).then(function (result) {{
        var wrapper = document.createElement("div");
        wrapper.className = "mermaid-svg";
        var scrollLayer = document.createElement("div");
        scrollLayer.className = "mermaid-svg-scroll";
        scrollLayer.innerHTML = result.svg;
        wrapper.appendChild(scrollLayer);
        block.replaceWith(wrapper);
        requestAnimationFrame(function () {{
          sanitizeMermaidSVG(wrapper);
        }});
      }}).catch(function (error) {{
        showFallback(block.closest(".mermaid-container"), String(error));
      }});
    }})).finally(markReady);
  }})();
  </script>
</body>
</html>
"""

output_path.write_text(html_doc, encoding="utf-8")
print(str(output_path))
PY

latest_html="$tmp_dir/latest.html"
cp "$output_html" "$latest_html"

echo "Generated preview HTML:"
echo "  $output_html"
echo "Latest preview HTML:"
echo "  $latest_html"

if [[ "$open_after_generate" == "1" ]]; then
  open "$latest_html"
fi
