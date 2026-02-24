import Foundation
import UIKit
import WebKit

@MainActor
final class ImageExportService {
    private let snapshotter: WebViewSnapshotter
    private let encoder: ImageFormatEncoder
    private let limits: ExportLimits

    init(
        limits: ExportLimits? = nil,
        encoder: ImageFormatEncoder = ImageFormatEncoder()
    ) {
        let resolvedLimits = limits ?? Self.deviceFittedDefaultLimits()
        self.limits = resolvedLimits
        self.snapshotter = WebViewSnapshotter(limits: resolvedLimits)
        self.encoder = encoder
    }

    func exportSingleImage(
        from webView: WKWebView?,
        preferredFormat: ExportFormat,
        htmlForBackgroundExport: String? = nil,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> (fileURL: URL, formatUsed: ExportFormat) {
        let exportWebView: WKWebView
        let cleanup: (() -> Void)

        if let htmlForBackgroundExport {
            let background = makeBackgroundWebView(html: htmlForBackgroundExport)
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

    private func makeBackgroundWebView(html: String) -> (webView: WKWebView, hostView: UIView?) {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let frame = CGRect(x: 0, y: 0, width: limits.targetWidth, height: 1200)
        let webView = WKWebView(frame: frame, configuration: configuration)
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

        webView.loadHTMLString(html, baseURL: nil)
        return (webView, hostView)
    }

    private static func deviceFittedDefaultLimits() -> ExportLimits {
        let base = ExportLimits.default
        let screenScale = UIScreen.main.scale
        let screenWidthPoints = UIScreen.main.bounds.width
        let fittedTargetWidth = max(320, floor(screenWidthPoints * screenScale))
        return ExportLimits(
            targetWidth: fittedTargetWidth,
            maxPixelCount: base.maxPixelCount,
            tileHeight: base.tileHeight
        )
    }
}
