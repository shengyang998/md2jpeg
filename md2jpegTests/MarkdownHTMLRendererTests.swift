import XCTest
@testable import md2jpeg

final class MarkdownHTMLRendererTests: XCTestCase {
    func testRendererProducesHTMLDocument() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "# Title", theme: .classic)
        XCTAssertTrue(html.contains("<!doctype html>"))
        XCTAssertTrue(html.contains("markdown-root"))
    }

    func testRendererEscapesUnsafeFallbackCharacters() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "<script>", theme: .dark)
        XCTAssertTrue(html.contains("&lt;script&gt;"))
    }

    func testRendererKeepsLeadingLineContent() {
        let renderer = MarkdownHTMLRenderer()
        let markdown = "# FirstLineHeading\n\nSecond paragraph"
        let html = renderer.render(markdown: markdown, theme: .classic)
        XCTAssertTrue(html.contains("FirstLineHeading"))
    }

    func testRendererParsesMarkdownTable() {
        let renderer = MarkdownHTMLRenderer()
        let markdown = """
        | Name | Value |
        | --- | --- |
        | Alpha | 1 |
        | Beta | 2 |
        """
        let html = renderer.render(markdown: markdown, theme: .classic)

        XCTAssertTrue(html.contains("<table>"))
        XCTAssertTrue(html.contains("<th>Name</th>"))
        XCTAssertTrue(html.contains("<td>Alpha</td>"))
        XCTAssertTrue(html.contains("<td>2</td>"))
    }

    func testRendererParsesSevenHashHeadingAsTitleLevel() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "####### Deep Title", theme: .classic)

        XCTAssertTrue(html.contains("<h6 data-md-heading-level=\"7\">Deep Title</h6>"))
    }

    func testRendererSupportsAsteriskAndDashBulletPoints() {
        let renderer = MarkdownHTMLRenderer()
        let markdown = """
        * First item
        - Second item
        """
        let html = renderer.render(markdown: markdown, theme: .classic)

        XCTAssertTrue(html.contains("<ul>"))
        XCTAssertTrue(html.contains("<li>First item</li>"))
        XCTAssertTrue(html.contains("<li>Second item</li>"))
    }

    func testRendererSupportsHorizontalRuleSeparator() {
        let renderer = MarkdownHTMLRenderer()
        let markdown = """
        Paragraph A
        ---
        Paragraph B
        """
        let html = renderer.render(markdown: markdown, theme: .classic)

        XCTAssertTrue(html.contains("<p>Paragraph A</p>"))
        XCTAssertTrue(html.contains("<hr />"))
        XCTAssertTrue(html.contains("<p>Paragraph B</p>"))
    }

    func testRendererSupportsAsteriskAndUnderscoreHorizontalRules() {
        let renderer = MarkdownHTMLRenderer()
        let markdown = """
        Top
        * * *
        Middle
        ___
        Bottom
        """
        let html = renderer.render(markdown: markdown, theme: .classic)

        let hrCount = html.components(separatedBy: "<hr />").count - 1
        XCTAssertEqual(hrCount, 2)
        XCTAssertTrue(html.contains("<p>Top</p>"))
        XCTAssertTrue(html.contains("<p>Middle</p>"))
        XCTAssertTrue(html.contains("<p>Bottom</p>"))
    }

    func testRendererBuildsMermaidContainerForFencedBlocks() {
        let renderer = MarkdownHTMLRenderer()
        let markdown = """
        ```mermaid
        graph TD
          A --> B
        ```
        """
        let html = renderer.render(markdown: markdown, theme: .paper)

        XCTAssertTrue(html.contains("class=\"mermaid-container\""))
        XCTAssertTrue(html.contains("class=\"mermaid\""))
        XCTAssertTrue(html.contains("graph TD"))
        XCTAssertTrue(html.contains("data-md2jpeg-ready"))
    }

    func testRendererEscapesMermaidSourceHTML() {
        let renderer = MarkdownHTMLRenderer()
        let markdown = """
        ```mermaid
        graph TD
          A[<script>alert(1)</script>] --> B
        ```
        """
        let html = renderer.render(markdown: markdown, theme: .dark)

        XCTAssertFalse(html.contains("<script>alert(1)</script>"))
        XCTAssertTrue(html.contains("&lt;script&gt;alert(1)&lt;/script&gt;"))
    }

    func testRendererSupportsMixedFixtureContent() throws {
        let renderer = MarkdownHTMLRenderer()
        let fixtureURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent("mixed-content.md")
        let markdown = try String(contentsOf: fixtureURL)
        let html = renderer.render(markdown: markdown, theme: .classic)

        XCTAssertTrue(html.contains("<table>"))
        XCTAssertTrue(html.contains("class=\"mermaid-container\""))
        XCTAssertTrue(html.contains("Engineering Notes"))
    }

    func testRendererSupportsMermaidMindmapFixture() throws {
        let renderer = MarkdownHTMLRenderer()
        let fixtureURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent("mermaid-mindmap.md")
        let markdown = try String(contentsOf: fixtureURL)
        let html = renderer.render(markdown: markdown, theme: .classic)

        XCTAssertTrue(html.contains("class=\"mermaid-container\""))
        XCTAssertTrue(html.contains("mindmap"))
        XCTAssertTrue(html.contains("root((md2jpeg))"))
    }

    func testRendererAppliesDarkMermaidThemeConfig() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "```mermaid\ngraph TD\nA-->B\n```", theme: .dark)

        XCTAssertTrue(html.contains("\"theme\":\"base\""))
        XCTAssertTrue(html.contains("\"darkMode\":true"))
        XCTAssertTrue(html.contains("\"lineColor\":\"#60a5fa\""))
    }

    func testRendererAppliesPaperMermaidThemeConfig() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "```mermaid\ngraph TD\nA-->B\n```", theme: .paper)

        XCTAssertTrue(html.contains("\"theme\":\"base\""))
        XCTAssertTrue(html.contains("\"primaryColor\":\"#f5ede2\""))
        XCTAssertTrue(html.contains("\"lineColor\":\"#92400e\""))
    }

    func testRendererAppliesClassicMermaidThemeConfig() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "```mermaid\ngraph TD\nA-->B\n```", theme: .classic)

        XCTAssertTrue(html.contains("\"theme\":\"base\""))
        XCTAssertTrue(html.contains("\"primaryColor\":\"#eef2ff\""))
        XCTAssertTrue(html.contains("\"lineColor\":\"#6366f1\""))
    }

    func testRendererPinsMermaidRuntimeVersion() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "```mermaid\ngraph TD\nA-->B\n```", theme: .classic)

        XCTAssertTrue(html.contains("mermaid@10.9.5"))
        XCTAssertFalse(html.contains("mermaid@10/dist"))
    }

    func testRendererInjectsMermaidNormalizationAndDiagnosticsHooks() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "```mermaid\ngraph TD\nA-->B\n```", theme: .dark)

        XCTAssertTrue(html.contains("normalizeMermaidSource"))
        XCTAssertTrue(html.contains("md2jpegMermaidLog"))
        XCTAssertTrue(html.contains("class=\"mermaid-error-detail\""))
        XCTAssertTrue(html.contains("Mermaid render timed out after"))
    }

    // MARK: - Italic and Bold-Italic

    func testRendererSupportsItalicWithSingleAsterisk() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "*italic text*", theme: .classic)
        XCTAssertTrue(html.contains("<em>italic text</em>"))
    }

    func testRendererSupportsBoldItalicWithTripleAsterisk() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "***bold italic***", theme: .classic)
        XCTAssertTrue(html.contains("<strong><em>bold italic</em></strong>"))
    }

    func testRendererSupportsMixedEmphasisOnSameLine() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "**bold** and *italic*", theme: .classic)
        XCTAssertTrue(html.contains("<strong>bold</strong>"))
        XCTAssertTrue(html.contains("<em>italic</em>"))
    }

    func testRendererHandlesAllEmphasisLevelsOnSameLine() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "***all*** then **bold** then *italic*", theme: .classic)
        XCTAssertTrue(html.contains("<strong><em>all</em></strong>"))
        XCTAssertTrue(html.contains("<strong>bold</strong>"))
        XCTAssertTrue(html.contains("<em>italic</em>"))
    }

    func testRendererLeavesUnmatchedAsteriskAsIs() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "price is 5*3", theme: .classic)
        XCTAssertFalse(html.contains("<em>"))
        XCTAssertTrue(html.contains("5*3"))
    }

    func testRendererKeepsBoldWorkingAfterRefactor() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "**bold text**", theme: .classic)
        XCTAssertTrue(html.contains("<strong>bold text</strong>"))
    }

    // MARK: - Display Math

    func testRendererSupportsMultiLineDisplayMath() {
        let renderer = MarkdownHTMLRenderer()
        let markdown = "$$\n\\sum_{i=0}^{n} i\n$$"
        let html = renderer.render(markdown: markdown, theme: .classic)
        XCTAssertTrue(html.contains("class=\"math-display\""))
        XCTAssertTrue(html.contains("data-latex="))
    }

    func testRendererSupportsSingleLineDisplayMath() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "$$E = mc^2$$", theme: .classic)
        XCTAssertTrue(html.contains("class=\"math-display\""))
        XCTAssertTrue(html.contains("E = mc^2"))
    }

    func testRendererIgnoresEmptyDisplayMath() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "$$$$", theme: .classic)
        XCTAssertFalse(html.contains("class=\"math-display\""))
    }

    func testRendererDisplayMathPreservesRawLatex() {
        let renderer = MarkdownHTMLRenderer()
        let markdown = "$$\nx < y\n$$"
        let html = renderer.render(markdown: markdown, theme: .classic)
        XCTAssertTrue(html.contains("data-latex="))
        XCTAssertTrue(html.contains("x &lt; y"))
    }

    // MARK: - Inline Math

    func testRendererSupportsInlineMath() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "The equation $E = mc^2$ is famous", theme: .classic)
        XCTAssertTrue(html.contains("class=\"math-inline\""))
        XCTAssertTrue(html.contains("E = mc^2"))
    }

    func testRendererRejectsDollarSignWithAdjacentWhitespace() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "costs $ 5.00 $ today", theme: .classic)
        XCTAssertFalse(html.contains("class=\"math-inline\""))
    }

    func testRendererInlineMathPreservesAngleBrackets() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "if $x < y$ then", theme: .classic)
        XCTAssertTrue(html.contains("class=\"math-inline\""))
        XCTAssertTrue(html.contains("data-latex=\"x &lt; y\""))
    }

    func testRendererInlineMathPreservesAmpersand() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "use $A \\& B$ here", theme: .classic)
        XCTAssertTrue(html.contains("class=\"math-inline\""))
        XCTAssertTrue(html.contains("&amp;"))
    }

    func testRendererMultipleInlineMathOnSameLine() {
        let renderer = MarkdownHTMLRenderer()
        let html = renderer.render(markdown: "$a$ and $b$", theme: .classic)
        let mathCount = html.components(separatedBy: "class=\"math-inline\"").count - 1
        XCTAssertEqual(mathCount, 2)
    }

    func testRendererKeepsOriginalMermaidCompatibilitySourceInFallback() throws {
        let renderer = MarkdownHTMLRenderer()
        let fixtureURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent("mermaid-compatibility.md")
        let markdown = try String(contentsOf: fixtureURL)
        let html = renderer.render(markdown: markdown, theme: .classic)

        XCTAssertTrue(html.contains("graph TD"))
        XCTAssertTrue(html.contains("style A fill:#000,stroke:#f66"))
        XCTAssertTrue(html.contains("class=\"mermaid-error-detail\""))
    }

    func testRendererIncludesMermaidContainerAndSVGPolishInClassicTheme() throws {
        let renderer = MarkdownHTMLRenderer()
        let fixtureURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent("mermaid-mindmap.md")
        let markdown = try String(contentsOf: fixtureURL)
        let html = renderer.render(markdown: markdown, theme: .classic)

        XCTAssertTrue(html.contains(".edgePath .path"))
        XCTAssertTrue(html.contains("border-radius: 12px"))
        XCTAssertTrue(html.contains("background: #fafaff"))
    }

    func testRendererSupportsMultipleMermaidDiagramTypesFixture() throws {
        let renderer = MarkdownHTMLRenderer()
        let fixtureURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent("mermaid-multi-diagrams.md")
        let markdown = try String(contentsOf: fixtureURL)
        let html = renderer.render(markdown: markdown, theme: .paper)

        let mermaidContainerCount = html.components(separatedBy: "class=\"mermaid-container\"").count - 1
        XCTAssertEqual(mermaidContainerCount, 2)
        XCTAssertTrue(html.contains("flowchart LR"))
        XCTAssertTrue(html.contains("sequenceDiagram"))
        XCTAssertTrue(html.contains("border-radius: 10px"))
    }
}
