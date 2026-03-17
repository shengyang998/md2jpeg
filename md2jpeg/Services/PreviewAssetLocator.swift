import Foundation

enum PreviewAssetLocator {
    static let katexStylesheetPath = "Vendor/katex/katex.min.css"
    static let katexScriptPath = "Vendor/katex/katex.min.js"
    static let mermaidScriptPath = "Vendor/mermaid/mermaid.min.js"

    static var htmlBaseURL: URL? {
        Bundle.main.resourceURL
    }
}
