import Foundation

enum HTMLTemplateBuilder {
    // Keep Mermaid runtime deterministic. Upgrade by validating fixtures against
    // the candidate version, then updating this constant in one place.
    private static let pinnedMermaidVersion = "10.9.5"

    static func build(bodyHTML: String, css: String, mermaidConfigJSON: String) -> String {
        """
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <script src="https://cdn.jsdelivr.net/npm/mermaid@\(pinnedMermaidVersion)/dist/mermaid.min.js" onerror="window.__md2jpegMermaidScriptFailed = true"></script>
          <style>
          \(css)
          </style>
        </head>
        <body data-md2jpeg-ready="false">
          <article class="markdown-root">\(bodyHTML)</article>
          <script>
          (function () {
            function logMermaidEvent(payload) {
              try {
                if (
                  window.webkit &&
                  window.webkit.messageHandlers &&
                  window.webkit.messageHandlers.md2jpegMermaidLog
                ) {
                  window.webkit.messageHandlers.md2jpegMermaidLog.postMessage(payload);
                  return;
                }
              } catch (_) {}
              try {
                console.error("[md2jpeg-mermaid]", payload);
              } catch (_) {}
            }

            function markReady() {
              document.body.setAttribute("data-md2jpeg-ready", "true");
            }

            function normalizeMermaidSource(source) {
              if (typeof source !== "string") { return ""; }
              var normalized = source.replace(/\\r\\n?/g, "\\n").replace(/^\\uFEFF/, "");
              var firstLine = normalized.split("\\n").find(function (line) {
                return line.trim().length > 0;
              }) || "";
              var isMindmap = firstLine.trim() === "mindmap";
              // Keep normalization conservative: canonicalize flow header and quote
              // square-bracket labels that contain parser-sensitive characters.
              normalized = normalized.replace(
                /^(\\s*)graph(\\s+(?:TB|TD|BT|RL|LR)\\b)/m,
                "$1flowchart$2"
              );
              normalized = normalized.replace(
                /([A-Za-z_][A-Za-z0-9_]*)\\[([^\\]\\n]+)\\]/g,
                function (_, nodeId, rawLabel) {
                  var label = (rawLabel || "").trim();
                  if (label.length === 0) { return nodeId + "[]"; }
                  if (
                    (label.startsWith('"') && label.endsWith('"')) ||
                    (label.startsWith("'") && label.endsWith("'"))
                  ) {
                    return nodeId + "[" + label + "]";
                  }
                  var escaped = label.replace(/"/g, '\\\\"');
                  return nodeId + '["' + escaped + '"]';
                }
              );
              normalized = normalized.replace(
                /([A-Za-z_][A-Za-z0-9_]*)\\(([^\\)\\n]+)\\)/g,
                function (_, nodeId, rawLabel) {
                  var label = (rawLabel || "").trim();
                  if (label.length === 0) { return nodeId + "()"; }
                  if (
                    (label.startsWith('"') && label.endsWith('"')) ||
                    (label.startsWith("'") && label.endsWith("'"))
                  ) {
                    return nodeId + "(" + label + ")";
                  }
                  var escaped = label.replace(/"/g, '\\\\"');
                  return nodeId + '("' + escaped + '")';
                }
              );
              normalized = normalized.replace(
                /([A-Za-z_][A-Za-z0-9_]*)\\{([^\\}\\n]+)\\}/g,
                function (_, nodeId, rawLabel) {
                  var label = (rawLabel || "").trim();
                  if (label.length === 0) { return nodeId + "{}"; }
                  if (
                    (label.startsWith('"') && label.endsWith('"')) ||
                    (label.startsWith("'") && label.endsWith("'"))
                  ) {
                    return nodeId + "{" + label + "}";
                  }
                  var escaped = label.replace(/"/g, '\\\\"');
                  return nodeId + '{"' + escaped + '"}';
                }
              );
              normalized = normalized.replace(
                /\\|([^|\\n]+)\\|/g,
                function (_, rawLabel) {
                  var label = (rawLabel || "").trim();
                  if (label.length === 0) { return "||"; }
                  if (
                    (label.startsWith('"') && label.endsWith('"')) ||
                    (label.startsWith("'") && label.endsWith("'"))
                  ) {
                    return "|" + label + "|";
                  }
                  var escaped = label.replace(/"/g, '\\\\"');
                  return '|"'+ escaped + '"|';
                }
              );
              if (isMindmap) {
                normalized = normalized
                  .replace(/->/g, " to ");
                normalized = normalized
                  .split("\\n")
                  .map(function (line) {
                    var leading = (line.match(/^\\s*/) || [""])[0];
                    var body = line.slice(leading.length);
                    if (body.length === 0) { return line; }
                    if (body === "mindmap") { return "mindmap"; }
                    if (/^root\\s*\\(\\(/.test(body)) {
                      return leading + body.replace(/\\s{2,}/g, " ").trim();
                    }
                    body = body
                      .replace(/[\\[\\]\\{\\}\\(\\)\\|]/g, " ")
                      .replace(/[:：]/g, " - ")
                      .replace(/[?？]/g, " ")
                      .replace(/[\\/]/g, " ")
                      .replace(/[<>]/g, " ");
                    body = body.replace(/\\s{2,}/g, " ").trim();
                    return leading + body;
                  })
                  .join("\\n");
              }
              return normalized;
            }

            function formatErrorSummary(error) {
              if (!error) { return "unknown_error"; }
              if (typeof error === "string") {
                return error.slice(0, 240);
              }
              if (error.str && typeof error.str === "string") {
                return error.str.slice(0, 240);
              }
              if (error.message && typeof error.message === "string") {
                return error.message.slice(0, 240);
              }
              try {
                return JSON.stringify(error).slice(0, 240);
              } catch (_) {
                return "unserializable_error";
              }
            }

            function serializeError(error) {
              if (!error) { return null; }
              if (typeof error === "string") { return { message: error }; }
              return {
                name: error.name || null,
                message: error.message || null,
                stack: error.stack || null,
                str: error.str || null
              };
            }

            function showFallback(container, detailText) {
              if (!container) { return; }
              container.classList.add("mermaid-failed");
              var errorNode = container.querySelector(".mermaid-error");
              var detailNode = container.querySelector(".mermaid-error-detail");
              var sourceNode = container.querySelector(".mermaid-source-fallback");
              if (errorNode) { errorNode.hidden = false; }
              if (detailNode) {
                detailNode.hidden = false;
                detailNode.textContent = detailText || "No diagnostics available.";
              }
              if (sourceNode) { sourceNode.hidden = false; }
            }

            function renderMermaidBlocks() {
              var blocks = Array.prototype.slice.call(document.querySelectorAll("pre.mermaid"));
              if (blocks.length === 0) {
                markReady();
                return;
              }

              if (window.__md2jpegMermaidScriptFailed || typeof mermaid === "undefined") {
                blocks.forEach(function (block) {
                  showFallback(block.closest(".mermaid-container"), "Mermaid runtime failed to load.");
                });
                logMermaidEvent({
                  type: "runtime_load_error",
                  reason: "mermaid_undefined_or_script_failed",
                  blockCount: blocks.length
                });
                markReady();
                return;
              }

              var mermaidConfig = \(mermaidConfigJSON);
              mermaid.initialize(mermaidConfig);

              var timeoutMs = 2000;
              var timedOut = false;
              var timeoutHandle = setTimeout(function () {
                timedOut = true;
                blocks.forEach(function (block) {
                  showFallback(block.closest(".mermaid-container"), "Mermaid render timed out after " + timeoutMs + "ms.");
                });
                logMermaidEvent({
                  type: "render_timeout",
                  timeoutMs: timeoutMs,
                  blockCount: blocks.length
                });
                markReady();
              }, timeoutMs);

              Promise.all(
                blocks.map(function (block, index) {
                  var source = block.textContent || "";
                  var normalizedSource = normalizeMermaidSource(source);
                  return mermaid.render("md2jpeg-mermaid-" + index, normalizedSource).then(function (result) {
                    if (timedOut) { return; }
                    var wrapper = document.createElement("div");
                    wrapper.className = "mermaid-svg";
                    wrapper.innerHTML = result.svg;
                    block.replaceWith(wrapper);
                  }).catch(function (error) {
                    if (timedOut) { return; }
                    var detail = formatErrorSummary(error);
                    showFallback(block.closest(".mermaid-container"), detail);
                    logMermaidEvent({
                      type: "render_error",
                      index: index,
                      diagnostics: detail,
                      source: source,
                      normalizedSource: normalizedSource,
                      error: serializeError(error)
                    });
                  });
                })
              ).finally(function () {
                if (timedOut) { return; }
                clearTimeout(timeoutHandle);
                markReady();
              });
            }

            if (document.readyState === "loading") {
              document.addEventListener("DOMContentLoaded", renderMermaidBlocks);
            } else {
              renderMermaidBlocks();
            }
          })();
          </script>
        </body>
        </html>
        """
    }
}
