import SwiftUI
import WebKit
import os

final class MermaidLogScriptMessageHandler: NSObject, WKScriptMessageHandler {
    private static let logger = Logger(subsystem: "md2jpeg", category: "mermaid")

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "md2jpegMermaidLog" else { return }
        if
            let dictionary = message.body as? [String: Any],
            let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [.sortedKeys]),
            let json = String(data: data, encoding: .utf8)
        {
            Self.logger.error("Mermaid event: \(json, privacy: .public)")
            return
        }
        Self.logger.error("Mermaid event: \(String(describing: message.body), privacy: .public)")
    }
}

final class PreviewWebView: WKWebView {
    var lastLoadedHTMLFingerprint: Int?
    var pendingRestoreOffsetY: CGFloat?
}

struct MarkdownPreviewWebView: UIViewRepresentable {
    let html: String
    let onLoadingStateChange: (Bool) -> Void
    let onError: (String?) -> Void
    let onWebViewCreated: (WKWebView) -> Void
    let onTopEdgePullDown: (CGFloat) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onLoadingStateChange: onLoadingStateChange,
            onError: onError,
            onTopEdgePullDown: onTopEdgePullDown
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.userContentController.add(MermaidLogScriptMessageHandler(), name: "md2jpegMermaidLog")
        let webView = PreviewWebView(frame: .zero, configuration: configuration)
        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif
        webView.navigationDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.keyboardDismissMode = .onDrag
        onWebViewCreated(webView)
        context.coordinator.loadIfNeeded(html: html, into: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.loadIfNeeded(html: html, into: uiView)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
        private static let logger = Logger(subsystem: "md2jpeg", category: "preview")
        let onLoadingStateChange: (Bool) -> Void
        let onError: (String?) -> Void
        let onTopEdgePullDown: (CGFloat) -> Void

        init(
            onLoadingStateChange: @escaping (Bool) -> Void,
            onError: @escaping (String?) -> Void,
            onTopEdgePullDown: @escaping (CGFloat) -> Void
        ) {
            self.onLoadingStateChange = onLoadingStateChange
            self.onError = onError
            self.onTopEdgePullDown = onTopEdgePullDown
        }

        func loadIfNeeded(html: String, into webView: WKWebView) {
            let fingerprint = html.hashValue
            if let previewWebView = webView as? PreviewWebView, previewWebView.lastLoadedHTMLFingerprint == fingerprint {
                Self.logger.debug("Skipping preview reload; html fingerprint unchanged")
                return
            }

            if let previewWebView = webView as? PreviewWebView {
                previewWebView.lastLoadedHTMLFingerprint = fingerprint
                previewWebView.pendingRestoreOffsetY = webView.scrollView.contentOffset.y
            }
            Self.logger.debug("Loading preview HTML. fingerprint=\(fingerprint, privacy: .public)")
            webView.loadHTMLString(html, baseURL: nil)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            Self.logger.debug("Preview navigation started")
            onError(nil)
            onLoadingStateChange(true)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Self.logger.debug("Preview navigation finished")
            restoreScrollOffsetIfNeeded(in: webView)
            onLoadingStateChange(false)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Self.logger.error("Preview navigation failed: \(error.localizedDescription, privacy: .public)")
            onLoadingStateChange(false)
            onError(error.localizedDescription)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            Self.logger.error("Preview provisional navigation failed: \(error.localizedDescription, privacy: .public)")
            onLoadingStateChange(false)
            onError(error.localizedDescription)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView.contentOffset.y < 0 else { return }
            onTopEdgePullDown(abs(scrollView.contentOffset.y))
        }

        private func restoreScrollOffsetIfNeeded(in webView: WKWebView) {
            guard
                let previewWebView = webView as? PreviewWebView,
                let previousOffsetY = previewWebView.pendingRestoreOffsetY
            else {
                return
            }

            let maxOffsetY = max(webView.scrollView.contentSize.height - webView.scrollView.bounds.height, 0)
            let targetOffsetY = min(max(previousOffsetY, 0), maxOffsetY)
            webView.scrollView.setContentOffset(CGPoint(x: 0, y: targetOffsetY), animated: false)
            previewWebView.pendingRestoreOffsetY = nil
        }
    }
}
