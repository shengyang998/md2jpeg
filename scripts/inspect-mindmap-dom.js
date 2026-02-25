#!/usr/bin/env node

/**
 * Script to inspect Mermaid mindmap DOM structure
 * This script opens the HTML file in a headless browser and extracts
 * the exact DOM structure of mindmap node labels.
 */

const fs = require('fs');
const path = require('path');

// Read the HTML file
const htmlPath = process.argv[2] || path.join(__dirname, '.tmp', 'latest.html');
const htmlContent = fs.readFileSync(htmlPath, 'utf-8');

// Extract the mermaid source
const mermaidMatch = htmlContent.match(/<pre class="mermaid">([\s\S]*?)<\/pre>/);
if (!mermaidMatch) {
  console.error('Could not find mermaid diagram in HTML');
  process.exit(1);
}

const mermaidSource = mermaidMatch[1].trim();

// Create a simple HTML page that will render and inspect
const inspectorHTML = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10.9.5/dist/mermaid.min.js"></script>
</head>
<body>
  <div id="diagram"></div>
  <script>
    mermaid.initialize({
      theme: "base",
      startOnLoad: false,
      securityLevel: "strict",
      themeVariables: {
        fontFamily: "-apple-system, BlinkMacSystemFont, \\"Segoe UI\\", sans-serif",
        fontSize: "14px",
        darkMode: true,
        primaryColor: "#1e293b",
        primaryTextColor: "#e2e8f0",
        primaryBorderColor: "#475569",
        lineColor: "#60a5fa",
        secondaryColor: "#0f172a",
        tertiaryColor: "#1e293b",
        background: "#0f172a",
        mainBkg: "#1e293b",
        textColor: "#e2e8f0",
        noteBkgColor: "#1e293b",
        noteTextColor: "#94a3b8",
        noteBorderColor: "#475569",
        cScale0: "#243352",
        cScaleLabel0: "#ffffff"
      }
    });
    
    const source = \`${mermaidSource}\`;
    
    mermaid.render("diagram-svg", source).then(result => {
      document.getElementById('diagram').innerHTML = result.svg;
      
      // Wait for rendering to complete
      setTimeout(() => {
        const svg = document.querySelector('#diagram svg');
        if (!svg) {
          console.log('ERROR: SVG not found');
          return;
        }
        
        const nodes = svg.querySelectorAll('.mindmap-node');
        console.log('=== MINDMAP DOM INSPECTION ===\\n');
        console.log('Total nodes found:', nodes.length, '\\n');
        
        nodes.forEach((node, idx) => {
          const textEl = node.querySelector('text');
          if (!textEl) return;
          
          const textContent = textEl.textContent.trim();
          
          // Focus on non-root nodes, especially "Preview"
          if (textContent === 'Preview' || (idx >= 3 && idx <= 6)) {
            console.log('\\n=== NODE:', textContent, '(index', idx + ') ===');
            console.log('Parent g classes:', node.getAttribute('class'));
            console.log('\\n<text> element:');
            console.log('  id:', textEl.getAttribute('id'));
            console.log('  class:', textEl.getAttribute('class'));
            console.log('  transform:', textEl.getAttribute('transform'));
            console.log('  text-anchor:', textEl.getAttribute('text-anchor'));
            console.log('  dominant-baseline:', textEl.getAttribute('dominant-baseline'));
            console.log('  alignment-baseline:', textEl.getAttribute('alignment-baseline'));
            console.log('  y:', textEl.getAttribute('y'));
            console.log('  dy:', textEl.getAttribute('dy'));
            console.log('  style:', textEl.getAttribute('style'));
            
            const tspans = textEl.querySelectorAll('tspan');
            console.log('\\n  <tspan> elements (' + tspans.length + ' total):');
            tspans.forEach((tspan, tIdx) => {
              console.log('    tspan[' + tIdx + ']:');
              console.log('      class:', tspan.getAttribute('class'));
              console.log('      x:', tspan.getAttribute('x'));
              console.log('      y:', tspan.getAttribute('y'));
              console.log('      dy:', tspan.getAttribute('dy'));
              console.log('      dominant-baseline:', tspan.getAttribute('dominant-baseline'));
              console.log('      alignment-baseline:', tspan.getAttribute('alignment-baseline'));
              console.log('      text-anchor:', tspan.getAttribute('text-anchor'));
              console.log('      style:', tspan.getAttribute('style'));
              console.log('      textContent:', '"' + tspan.textContent + '"');
            });
            
            console.log('\\n  Full outerHTML:');
            console.log(textEl.outerHTML);
          }
        });
        
      }, 100);
    }).catch(err => {
      console.error('ERROR:', err.message);
    });
  </script>
</body>
</html>
`;

// Try using jsdom if available
try {
  const { JSDOM } = require('jsdom');
  
  const dom = new JSDOM(inspectorHTML, {
    runScripts: "dangerously",
    resources: "usable",
    beforeParse(window) {
      // Set up console to capture output
      window.console = console;
    }
  });
  
  // Keep process alive for async operations
  setTimeout(() => {
    process.exit(0);
  }, 5000);
  
} catch (err) {
  // jsdom not available, output the HTML for manual inspection
  console.log('jsdom not available. Please install it with: npm install jsdom');
  console.log('\\nAlternatively, save this HTML and open in a browser:');
  console.log('\\n' + inspectorHTML);
  
  const outputPath = path.join(__dirname, '.tmp', 'dom-inspector.html');
  fs.writeFileSync(outputPath, inspectorHTML);
  console.log('\\nHTML saved to:', outputPath);
  console.log('Open it in a browser and check the console for output.');
}
