# Mermaid Mindmap DOM Inspection Guide

## How to Inspect

1. Open `/Users/soleilyu/Code/self/md2jpeg/scripts/.tmp/dom-inspector.html` in Chrome
2. Open DevTools (Cmd+Option+I)
3. Check the Console tab for automated output
4. Or use Elements tab to manually inspect

## Expected DOM Structure for Non-Root Mindmap Nodes

Based on Mermaid 10.9.5 mindmap implementation, non-root nodes typically have this structure:

```html
<g class="mindmap-node section-{N}">
  <!-- Background shape -->
  <rect class="node-bkg node-no-border" .../>
  
  <!-- Text container -->
  <text
    id="..."
    class="mindmap-label"
    text-anchor="middle"
    dominant-baseline="middle"
    alignment-baseline="middle"
    transform="translate(x, y)"
    style="..."
  >
    <tspan
      class="text-outer-tspan"
      x="0"
      y="0"
      dy="0"
      text-anchor="middle"
      style="..."
    >
      <tspan class="text-inner-tspan">
        Preview
      </tspan>
    </tspan>
  </text>
</g>
```

## Key Attributes to Check

### On `<text>` element:
- `dominant-baseline`: Usually "middle" or "central" or may be absent
- `alignment-baseline`: Usually "middle" or "central" or may be absent
- `text-anchor`: Usually "middle" for centered text
- `transform`: Contains translate(x, y) positioning
- `y`: May be "0" or a specific value
- `dy`: May be used for vertical adjustment

### On `<tspan>` elements:
- `class`: Look for "text-outer-tspan" and "text-inner-tspan"
- `dy`: This is crucial - may have a value that affects vertical position
- `y`: Usually "0" or inherits from parent
- `x`: Usually "0" for centered text
- `dominant-baseline`, `alignment-baseline`: May be set or inherited

## CSS Selectors Needed

To shift text downward for vertical centering, we likely need one of these approaches:

### Approach 1: Adjust dy on tspans
```css
.mermaid-svg svg .mindmap-node:not(.section-root) text tspan {
  dy: 0.15em !important; /* Shift down slightly */
}
```

### Approach 2: Adjust text element itself
```css
.mermaid-svg svg .mindmap-node:not(.section-root) text {
  dominant-baseline: text-after-edge;
  /* or */
  transform: translateY(2px);
}
```

### Approach 3: Target specific tspan classes
```css
.mermaid-svg svg .mindmap-node .text-outer-tspan {
  dy: 0.15em !important;
}

.mermaid-svg svg .mindmap-node .text-inner-tspan {
  dy: 0.15em !important;
}
```

## What to Report

Please copy the console output or manually inspect and report:

1. **For the "Preview" node:**
   - Complete `<text>` element with all attributes
   - Complete `<tspan>` elements with all attributes
   - Any computed styles visible in DevTools

2. **Key questions:**
   - Is `dominant-baseline` set on `<text>` or `<tspan>`?
   - What is the current `dy` value on tspans?
   - Is there a `transform` on the text element?
   - What classes are on the tspan elements?

## Console Commands for Quick Inspection

Paste these in the Chrome Console after the diagram renders:

```javascript
// Find Preview node
const nodes = document.querySelectorAll('.mindmap-node');
const previewNode = Array.from(nodes).find(n => n.textContent.includes('Preview'));
const textEl = previewNode?.querySelector('text');

// Log structure
console.log('Text element:', textEl);
console.log('Attributes:', {
  id: textEl?.getAttribute('id'),
  class: textEl?.getAttribute('class'),
  transform: textEl?.getAttribute('transform'),
  'text-anchor': textEl?.getAttribute('text-anchor'),
  'dominant-baseline': textEl?.getAttribute('dominant-baseline'),
  'alignment-baseline': textEl?.getAttribute('alignment-baseline'),
  y: textEl?.getAttribute('y'),
  dy: textEl?.getAttribute('dy')
});

// Log tspans
const tspans = textEl?.querySelectorAll('tspan');
tspans?.forEach((tspan, i) => {
  console.log(`tspan[${i}]:`, {
    class: tspan.getAttribute('class'),
    x: tspan.getAttribute('x'),
    y: tspan.getAttribute('y'),
    dy: tspan.getAttribute('dy'),
    'dominant-baseline': tspan.getAttribute('dominant-baseline'),
    'alignment-baseline': tspan.getAttribute('alignment-baseline'),
    textContent: tspan.textContent
  });
});

// Log outerHTML
console.log('Full HTML:', textEl?.outerHTML);
```
