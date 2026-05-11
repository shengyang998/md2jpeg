import Foundation
import UIKit
import WebKit

@MainActor
final class ImageExportService {
    private let encoder: ImageFormatEncoder
    private let limitsOverride: ExportLimits?

    init(
        limits: ExportLimits? = nil,
        encoder: ImageFormatEncoder = ImageFormatEncoder()
    ) {
        self.limitsOverride = limits
        self.encoder = encoder
    }

    func exportSingleImage(
        from webView: WKWebView?,
        preferredFormat: ExportFormat,
        htmlForBackgroundExport: String? = nil,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> (fileURL: URL, formatUsed: ExportFormat) {
        // Resolve limits per-export so we pick up the current screen size (handles rotation
        // and resized scenes on iPad / Catalyst). Tests can inject a fixed override.
        let limits = limitsOverride ?? Self.deviceFittedDefaultLimits()
        let snapshotter = WebViewSnapshotter(limits: limits)

        let exportWebView: WKWebView
        let cleanup: (() -> Void)

        if let htmlForBackgroundExport {
            let background = makeBackgroundWebView(html: htmlForBackgroundExport, limits: limits)
            exportWebView = background.webView
            cleanup = {
                background.webView.stopLoading()
                background.hostView?.removeFromSuperview()
            }
        } else {
            guard let webView else {
                throw ExportError.missingWebView
            }
            exportWebView = webView
            cleanup = {}
        }
        defer { cleanup() }

        let image = try await snapshotter.snapshotLongImage(from: exportWebView, onProgress: onProgress)
        onProgress?(0.98)
        let fileURL = makeOutputURL(format: preferredFormat)
        let result = try encoder.encode(image: image, preferredFormat: preferredFormat, outputURL: fileURL)
        onProgress?(1.0)
        return (result.fileURL, result.usedFormat)
    }

    private func makeOutputURL(format: ExportFormat) -> URL {
        let fileName = "markdown-\(UUID().uuidString).\(format.fileExtension)"
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }

    private func makeBackgroundWebView(html: String, limits: ExportLimits) -> (webView: WKWebView, hostView: UIView?) {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.userContentController.add(MermaidLogScriptMessageHandler(), name: "md2jpegMermaidLog")

        let frame = CGRect(x: 0, y: 0, width: limits.targetWidth, height: 1200)
        let webView = WKWebView(frame: frame, configuration: configuration)
        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.isScrollEnabled = true

        var hostView: UIView?
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        {
            let host = UIView(frame: CGRect(x: -20_000, y: 0, width: frame.width, height: frame.height))
            host.alpha = 0.01
            host.isUserInteractionEnabled = false
            host.addSubview(webView)
            window.addSubview(host)
            hostView = host
        }

        webView.loadHTMLString(html, baseURL: PreviewAssetLocator.htmlBaseURL)
        return (webView, hostView)
    }

    private static func deviceFittedDefaultLimits() -> ExportLimits {
        let base = ExportLimits.default
        // Use the current key window's bounds when available so resized scenes (iPad split view,
        // Catalyst windows) export at the size the user is actually seeing. Fall back to
        // UIScreen.main for first-launch ordering quirks.
        let referenceWidth: CGFloat
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        {
            referenceWidth = window.bounds.width
        } else {
            referenceWidth = UIScreen.main.bounds.width
        }
        let screenScale = UIScreen.main.scale
        let fittedLayoutWidth = max(320, floor(referenceWidth))
        return ExportLimits(
            targetWidth: fittedLayoutWidth,
            pixelScale: screenScale,
            maxPixelCount: base.maxPixelCount,
            tileHeight: base.tileHeight
        )
    }
}
