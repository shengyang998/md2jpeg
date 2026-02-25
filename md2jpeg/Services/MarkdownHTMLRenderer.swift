import Foundation

struct MarkdownHTMLRenderer {
    func render(markdown: String, theme: ThemePreset) -> String {
        let htmlBody = stableMarkdownToHTML(markdown)
        return HTMLTemplateBuilder.build(
            bodyHTML: htmlBody,
            css: loadThemeCSS(theme: theme),
            mermaidConfigJSON: mermaidConfigJSON(for: theme)
        )
    }

    private func loadThemeCSS(theme: ThemePreset) -> String {
        guard
            let url = Bundle.main.url(forResource: theme.cssFileName, withExtension: "css"),
            let css = try? String(contentsOf: url)
        else {
            return """
            body { font-family: -apple-system; color: #111; background: #fff; padding: 24px; }
            pre, code { font-family: Menlo, monospace; }
            """
        }
        return css
    }

    // Keep markdown conversion deterministic so WebView reload checks remain stable.
    private func stableMarkdownToHTML(_ markdown: String) -> String {
        let lines = markdown.components(separatedBy: .newlines)
        var htmlParts: [String] = []
        var inCodeBlock = false
        var codeFenceLanguage = ""
        var codeBuffer: [String] = []
        var inList = false
        var index = 0

        while index < lines.count {
            let rawLine = lines[index]
            let line = rawLine.trimmingCharacters(in: .whitespaces)

            if line.hasPrefix("```") {
                if inList {
                    htmlParts.append("</ul>")
                    inList = false
                }
                if inCodeBlock {
                    htmlParts.append(renderCodeBlock(language: codeFenceLanguage, lines: codeBuffer))
                    inCodeBlock = false
                    codeFenceLanguage = ""
                    codeBuffer = []
                } else {
                    inCodeBlock = true
                    codeFenceLanguage = String(line.dropFirst(3))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .lowercased()
                    codeBuffer = []
                }
                index += 1
                continue
            }

            if inCodeBlock {
                codeBuffer.append(rawLine)
                index += 1
                continue
            }

            if line.isEmpty {
                if inList {
                    htmlParts.append("</ul>")
                    inList = false
                }
                index += 1
                continue
            }

            if isHorizontalRule(line) {
                if inList {
                    htmlParts.append("</ul>")
                    inList = false
                }
                htmlParts.append("<hr />")
                index += 1
                continue
            }

            if let listItemContent = parseUnorderedListItem(line) {
                if !inList {
                    htmlParts.append("<ul>")
                    inList = true
                }
                htmlParts.append("<li>\(applyInlineFormatting(to: escapeHTML(listItemContent)))</li>")
                index += 1
                continue
            } else if inList {
                htmlParts.append("</ul>")
                inList = false
            }

            if let table = parseTable(from: lines, startIndex: index) {
                htmlParts.append(table.html)
                index = table.nextIndex
                continue
            }

            if let heading = parseHeading(line) {
                htmlParts.append(renderHeading(level: heading.level, text: heading.text))
            } else {
                htmlParts.append("<p>\(applyInlineFormatting(to: escapeHTML(rawLine)))</p>")
            }
            index += 1
        }

        if inList {
            htmlParts.append("</ul>")
        }
        if inCodeBlock {
            htmlParts.append(renderCodeBlock(language: codeFenceLanguage, lines: codeBuffer))
        }

        return htmlParts.joined(separator: "\n")
    }

    private func renderCodeBlock(language: String, lines: [String]) -> String {
        let source = lines.joined(separator: "\n")
        let escapedSource = escapeHTML(source)
        if language == "mermaid" {
            return """
            <div class="mermaid-container" data-mermaid-container="true">
              <pre class="mermaid">\(escapedSource)</pre>
              <div class="mermaid-error" hidden>Unable to render Mermaid diagram.</div>
              <div class="mermaid-error-detail" hidden></div>
              <pre class="mermaid-source-fallback" hidden>\(escapedSource)</pre>
            </div>
            """
        }
        return "<pre><code>\(escapedSource)</code></pre>"
    }

    private func parseTable(from lines: [String], startIndex: Int) -> (html: String, nextIndex: Int)? {
        guard startIndex + 1 < lines.count else { return nil }
        let headerLine = lines[startIndex].trimmingCharacters(in: .whitespaces)
        let delimiterLine = lines[startIndex + 1].trimmingCharacters(in: .whitespaces)
        guard isPotentialTableRow(headerLine), isDelimiterRow(delimiterLine) else {
            return nil
        }

        let headerCells = parseTableCells(from: headerLine)
        let delimiterCells = parseTableCells(from: delimiterLine)
        guard !headerCells.isEmpty, delimiterCells.count == headerCells.count else {
            return nil
        }

        var bodyRows: [[String]] = []
        var nextIndex = startIndex + 2
        while nextIndex < lines.count {
            let row = lines[nextIndex].trimmingCharacters(in: .whitespaces)
            guard isPotentialTableRow(row) else { break }
            let cells = parseTableCells(from: row)
            guard cells.count == headerCells.count else { break }
            bodyRows.append(cells)
            nextIndex += 1
        }

        var tableHTML: [String] = []
        tableHTML.append("<table>")
        tableHTML.append("<thead><tr>")
        for cell in headerCells {
            tableHTML.append("<th>\(applyInlineFormatting(to: escapeHTML(cell)))</th>")
        }
        tableHTML.append("</tr></thead>")
        if !bodyRows.isEmpty {
            tableHTML.append("<tbody>")
            for row in bodyRows {
                tableHTML.append("<tr>")
                for cell in row {
                    tableHTML.append("<td>\(applyInlineFormatting(to: escapeHTML(cell)))</td>")
                }
                tableHTML.append("</tr>")
            }
            tableHTML.append("</tbody>")
        }
        tableHTML.append("</table>")
        return (tableHTML.joined(separator: ""), nextIndex)
    }

    private func isPotentialTableRow(_ line: String) -> Bool {
        line.contains("|")
    }

    private func isDelimiterRow(_ line: String) -> Bool {
        let cells = parseTableCells(from: line)
        guard !cells.isEmpty else { return false }
        return cells.allSatisfy { cell in
            let trimmed = cell.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return false }
            let noEdgeColons = trimmed
                .trimmingCharacters(in: CharacterSet(charactersIn: ":"))
                .replacingOccurrences(of: " ", with: "")
            guard noEdgeColons.count >= 3 else { return false }
            return noEdgeColons.allSatisfy { $0 == "-" }
        }
    }

    private func parseTableCells(from line: String) -> [String] {
        var parts = line.split(separator: "|", omittingEmptySubsequences: false).map {
            String($0).trimmingCharacters(in: .whitespaces)
        }
        if parts.first?.isEmpty == true {
            parts.removeFirst()
        }
        if parts.last?.isEmpty == true {
            parts.removeLast()
        }
        return parts
    }

    private func isHorizontalRule(_ line: String) -> Bool {
        let compact = line.replacingOccurrences(of: " ", with: "")
        return compact == "---" || compact == "***" || compact == "___"
    }

    private func parseUnorderedListItem(_ line: String) -> String? {
        if line.hasPrefix("- ") || line.hasPrefix("* ") {
            return String(line.dropFirst(2))
        }
        return nil
    }

    private func parseHeading(_ line: String) -> (level: Int, text: String)? {
        var hashCount = 0
        for character in line {
            if character == "#" {
                hashCount += 1
            } else {
                break
            }
        }
        guard (1...7).contains(hashCount) else { return nil }

        let remainder = line.dropFirst(hashCount)
        guard remainder.first == " " else { return nil }
        let content = remainder.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return nil }

        return (hashCount, content)
    }

    private func renderHeading(level: Int, text: String) -> String {
        let escapedText = applyInlineFormatting(to: escapeHTML(text))
        if level <= 6 {
            return "<h\(level)>\(escapedText)</h\(level)>"
        }
        return "<h6 data-md-heading-level=\"\(level)\">\(escapedText)</h6>"
    }

    private func escapeHTML(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    private func applyInlineFormatting(to value: String) -> String {
        var result = value
        result = replaceDelimited("**", withTag: "strong", in: result)
        result = replaceDelimited("`", withTag: "code", in: result)
        return result
    }

    private func replaceDelimited(_ delimiter: String, withTag tag: String, in input: String) -> String {
        let parts = input.components(separatedBy: delimiter)
        guard parts.count >= 3 else { return input }

        var output = ""
        for (index, part) in parts.enumerated() {
            if index % 2 == 0 {
                output += part
            } else {
                output += "<\(tag)>\(part)</\(tag)>"
            }
        }
        return output
    }

    private func mermaidConfigJSON(for theme: ThemePreset) -> String {
        switch theme {
        case .classic:
            return """
            {"theme":"base","startOnLoad":false,"securityLevel":"strict","themeVariables":{"fontFamily":"-apple-system, BlinkMacSystemFont, \\"Segoe UI\\", sans-serif","fontSize":"14px","primaryColor":"#eef2ff","primaryTextColor":"#1e293b","primaryBorderColor":"#a5b4fc","lineColor":"#6366f1","secondaryColor":"#f1f5f9","tertiaryColor":"#e0e7ff","background":"#ffffff","mainBkg":"#eef2ff","textColor":"#1e293b","noteBkgColor":"#e0e7ff","noteTextColor":"#3730a3","noteBorderColor":"#a5b4fc","cScale0":"#e0e7ff","cScaleLabel0":"#312e81"}}
            """
        case .paper:
            return """
            {"theme":"base","startOnLoad":false,"securityLevel":"strict","themeVariables":{"fontFamily":"Georgia, \\"Times New Roman\\", serif","fontSize":"14px","primaryColor":"#f5ede2","primaryTextColor":"#1c1917","primaryBorderColor":"#d6b98e","lineColor":"#92400e","secondaryColor":"#faf7f2","tertiaryColor":"#ece0cf","background":"#faf7f2","mainBkg":"#f5ede2","textColor":"#1c1917","noteBkgColor":"#f5ede2","noteTextColor":"#78350f","noteBorderColor":"#d6b98e","cScale0":"#ede0cc","cScaleLabel0":"#451a03"}}
            """
        case .dark:
            return """
            {"theme":"base","startOnLoad":false,"securityLevel":"strict","themeVariables":{"fontFamily":"-apple-system, BlinkMacSystemFont, \\"Segoe UI\\", sans-serif","fontSize":"14px","darkMode":true,"primaryColor":"#1e293b","primaryTextColor":"#e2e8f0","primaryBorderColor":"#475569","lineColor":"#60a5fa","secondaryColor":"#0f172a","tertiaryColor":"#1e293b","background":"#0f172a","mainBkg":"#1e293b","textColor":"#e2e8f0","noteBkgColor":"#1e293b","noteTextColor":"#94a3b8","noteBorderColor":"#475569","cScale0":"#243352","cScaleLabel0":"#ffffff"}}
            """
        }
    }
}
