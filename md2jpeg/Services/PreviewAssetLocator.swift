import Foundation

enum PreviewAssetLocator {
    static var katexStylesheetPath: String {
        Bundle.main.url(forResource: "katex.min", withExtension: "css")?.absoluteString ?? "katex.min.css"
    }
    static var katexScriptPath: String {
        Bundle.main.url(forResource: "katex.min", withExtension: "js")?.absoluteString ?? "katex.min.js"
    }
    static var mermaidScriptPath: String {
        Bundle.main.url(forResource: "mermaid.min", withExtension: "js")?.absoluteString ?? "mermaid.min.js"
    }

    static var htmlBaseURL: URL? {
        Bundle.main.resourceURL
    }
}
