#!/usr/bin/env python3
"""
Inspect Mermaid mindmap DOM structure using Selenium
"""

import sys
import time
from pathlib import Path

try:
    from selenium import webdriver
    from selenium.webdriver.common.by import By
    from selenium.webdriver.support.ui import WebDriverWait
    from selenium.webdriver.support import expected_conditions as EC
    from selenium.webdriver.chrome.options import Options
except ImportError:
    print("ERROR: selenium not installed")
    print("Install with: pip3 install selenium")
    sys.exit(1)

def inspect_mindmap_dom(html_path):
    """Open HTML file and inspect the mindmap DOM structure"""
    
    # Setup Chrome in headless mode
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--disable-gpu')
    
    try:
        driver = webdriver.Chrome(options=chrome_options)
    except Exception as e:
        print(f"ERROR: Could not start Chrome driver: {e}")
        print("You may need to install chromedriver")
        sys.exit(1)
    
    try:
        # Load the page
        file_url = f"file://{html_path}"
        driver.get(file_url)
        
        # Wait for the diagram to render
        wait = WebDriverWait(driver, 10)
        wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, ".mindmap-node")))
        
        # Give extra time for complete rendering
        time.sleep(1)
        
        # Get all mindmap nodes
        nodes = driver.find_elements(By.CSS_SELECTOR, ".mindmap-node")
        
        print("=== MINDMAP DOM INSPECTION ===\n")
        print(f"Total nodes found: {len(nodes)}\n")
        
        for idx, node in enumerate(nodes):
            text_el = node.find_element(By.CSS_SELECTOR, "text")
            text_content = text_el.text.strip()
            
            # Focus on non-root nodes, especially "Preview"
            if text_content == "Preview" or (idx >= 3 and idx <= 6):
                print(f"\n=== NODE: {text_content} (index {idx}) ===")
                print(f"Parent g classes: {node.get_attribute('class')}")
                print(f"\n<text> element:")
                print(f"  id: {text_el.get_attribute('id')}")
                print(f"  class: {text_el.get_attribute('class')}")
                print(f"  transform: {text_el.get_attribute('transform')}")
                print(f"  text-anchor: {text_el.get_attribute('text-anchor')}")
                print(f"  dominant-baseline: {text_el.get_attribute('dominant-baseline')}")
                print(f"  alignment-baseline: {text_el.get_attribute('alignment-baseline')}")
                print(f"  y: {text_el.get_attribute('y')}")
                print(f"  dy: {text_el.get_attribute('dy')}")
                print(f"  style: {text_el.get_attribute('style')}")
                
                # Get tspan elements
                tspans = text_el.find_elements(By.CSS_SELECTOR, "tspan")
                print(f"\n  <tspan> elements ({len(tspans)} total):")
                for t_idx, tspan in enumerate(tspans):
                    print(f"    tspan[{t_idx}]:")
                    print(f"      class: {tspan.get_attribute('class')}")
                    print(f"      x: {tspan.get_attribute('x')}")
                    print(f"      y: {tspan.get_attribute('y')}")
                    print(f"      dy: {tspan.get_attribute('dy')}")
                    print(f"      dominant-baseline: {tspan.get_attribute('dominant-baseline')}")
                    print(f"      alignment-baseline: {tspan.get_attribute('alignment-baseline')}")
                    print(f"      text-anchor: {tspan.get_attribute('text-anchor')}")
                    print(f"      style: {tspan.get_attribute('style')}")
                    print(f'      textContent: "{tspan.text}"')
                
                print(f"\n  Full outerHTML:")
                print(text_el.get_attribute('outerHTML'))
        
    finally:
        driver.quit()

if __name__ == "__main__":
    html_path = sys.argv[1] if len(sys.argv) > 1 else "/Users/soleilyu/Code/self/md2jpeg/scripts/.tmp/dom-inspector.html"
    html_path = Path(html_path).absolute()
    
    if not html_path.exists():
        print(f"ERROR: File not found: {html_path}")
        sys.exit(1)
    
    inspect_mindmap_dom(html_path)
