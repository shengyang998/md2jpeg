import Foundation

enum HTMLTemplateBuilder {
    static func build(bodyHTML: String, css: String, mermaidConfigJSON: String) -> String {
        """
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js" onerror="window.__md2jpegMermaidScriptFailed = true"></script>
          <style>
          \(css)
          </style>
        </head>
        <body data-md2jpeg-ready="false">
          <article class="markdown-root">\(bodyHTML)</article>
          <script>
          (function () {
            function markReady() {
              document.body.setAttribute("data-md2jpeg-ready", "true");
            }

            function showFallback(container) {
              if (!container) { return; }
              container.classList.add("mermaid-failed");
              var errorNode = container.querySelector(".mermaid-error");
              var sourceNode = container.querySelector(".mermaid-source-fallback");
              if (errorNode) { errorNode.hidden = false; }
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
                  showFallback(block.closest(".mermaid-container"));
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
                  showFallback(block.closest(".mermaid-container"));
                });
                markReady();
              }, timeoutMs);

              Promise.all(
                blocks.map(function (block, index) {
                  var source = block.textContent || "";
                  return mermaid.render("md2jpeg-mermaid-" + index, source).then(function (result) {
                    if (timedOut) { return; }
                    var wrapper = document.createElement("div");
                    wrapper.className = "mermaid-svg";
                    wrapper.innerHTML = result.svg;
                    block.replaceWith(wrapper);
                  }).catch(function () {
                    if (timedOut) { return; }
                    showFallback(block.closest(".mermaid-container"));
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
