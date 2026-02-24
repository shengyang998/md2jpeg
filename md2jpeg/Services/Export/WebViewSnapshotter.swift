import UIKit
import WebKit

struct WebViewSnapshotter {
    let limits: ExportLimits
    private let maxReadinessAttempts = 6
    private let readinessDelayNs: UInt64 = 120_000_000
    private let sizeTolerance: CGFloat = 2.0
    private let requiredStableChecks = 2

    @MainActor
    func snapshotLongImage(
        from webView: WKWebView,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> UIImage {
        onProgress?(0.05)
        try await waitForDocumentReadiness(webView)
        let contentSize = await measuredDocumentSize(in: webView)
        guard contentSize.height > 0, contentSize.width > 0 else {
            throw ExportError.unableToMeasureContent
        }

        guard limits.isWithinBudget(contentHeight: contentSize.height) else {
            throw ExportError.contentExceedsLimit
        }

        let scale = limits.targetWidth / contentSize.width
        let targetSize = CGSize(width: limits.targetWidth, height: contentSize.height * scale)
        let tiles = makeContentTileRects(
            contentSize: contentSize,
            viewportHeight: max(webView.bounds.height, 1)
        )
        var capturedTiles: [(rect: CGRect, image: UIImage)] = []
        capturedTiles.reserveCapacity(tiles.count)
        let originalOffset = webView.scrollView.contentOffset
        defer { webView.scrollView.setContentOffset(originalOffset, animated: false) }

        for (index, tile) in tiles.enumerated() {
            let latestContentSize = await measuredDocumentSize(in: webView)
            let heightStable = abs(latestContentSize.height - contentSize.height) <= sizeTolerance
            let widthStable = abs(latestContentSize.width - contentSize.width) <= sizeTolerance
            guard heightStable && widthStable else {
                throw ExportError.unstableContentLayout
            }

            let configuration = WKSnapshotConfiguration()
            configuration.rect = CGRect(origin: .zero, size: tile.size)
            configuration.snapshotWidth = NSNumber(value: Float(tile.width * scale))

            webView.scrollView.setContentOffset(CGPoint(x: 0, y: tile.origin.y), animated: false)
            try await waitForTileReadiness(webView, expectedYOffset: tile.origin.y, isFirstTile: index == 0)

            let tileImage = try await snapshotTile(from: webView, configuration: configuration)
            try validateCapturedTile(tileImage, expectedTileSize: tile.size, scale: scale)
            let destinationRect = CGRect(
                x: 0,
                y: tile.origin.y * scale,
                width: tile.width * scale,
                height: tile.height * scale
            )
            capturedTiles.append((rect: destinationRect, image: tileImage))
            let tileProgress = Double(index + 1) / Double(max(tiles.count, 1))
            onProgress?(0.1 + (tileProgress * 0.8))
        }

        guard validateCoverage(capturedTiles: capturedTiles, targetSize: targetSize) else {
            throw ExportError.incompleteComposedImage
        }

        let image = UIGraphicsImageRenderer(size: targetSize).image { _ in
            for captured in capturedTiles {
                autoreleasepool {
                    captured.image.draw(in: captured.rect)
                }
            }
        }

        onProgress?(0.95)
        return image
    }

    func makeContentTileRects(contentSize: CGSize, viewportHeight: CGFloat) -> [CGRect] {
        var rects: [CGRect] = []
        var y: CGFloat = 0
        let contentTileHeight = min(max(viewportHeight, 1), max(limits.tileHeight, 1))

        while y < contentSize.height {
            let remaining = contentSize.height - y
            let height = min(contentTileHeight, remaining)
            rects.append(CGRect(x: 0, y: y, width: contentSize.width, height: height))
            y += height
        }

        return rects
    }

    @MainActor
    private func waitForDocumentReadiness(_ webView: WKWebView) async throws {
        for _ in 0..<maxReadinessAttempts {
            let contentSize = webView.scrollView.contentSize
            let ready = await isDocumentReady(webView)
            if ready && contentSize.height > 0 && contentSize.width > 0 {
                return
            }
            try await Task.sleep(nanoseconds: readinessDelayNs)
        }
        throw ExportError.unstableContentLayout
    }

    @MainActor
    private func waitForTileReadiness(_ webView: WKWebView, expectedYOffset: CGFloat, isFirstTile: Bool) async throws {
        let attempts = isFirstTile ? maxReadinessAttempts + 2 : maxReadinessAttempts
        var stableChecks = 0
        for _ in 0..<attempts {
            webView.layoutIfNeeded()
            let ready = await isDocumentReady(webView)
            let offsetDelta = abs(webView.scrollView.contentOffset.y - expectedYOffset)
            let scrollView = webView.scrollView
            let isScrollIdle = !scrollView.isDragging && !scrollView.isDecelerating && !scrollView.isTracking
            if ready && offsetDelta <= sizeTolerance && isScrollIdle {
                stableChecks += 1
                if stableChecks >= requiredStableChecks {
                    return
                }
            } else {
                stableChecks = 0
            }
            try await Task.sleep(nanoseconds: readinessDelayNs)
        }
        throw ExportError.incompleteTileCapture
    }

    @MainActor
    private func isDocumentReady(_ webView: WKWebView) async -> Bool {
        do {
            let value = try await evaluateJavaScript(
                """
                (function() {
                  return {
                    readyState: document.readyState,
                    md2jpegReady: document.body ? document.body.getAttribute("data-md2jpeg-ready") === "true" : null
                  };
                })();
                """,
                in: webView
            )
            return evaluateReadiness(value)
        } catch {
            // If JS cannot be evaluated, allow fallback to offset/content-size checks.
            return true
        }
    }

    func evaluateReadiness(_ value: Any?) -> Bool {
        guard let dictionary = value as? [String: Any] else {
            return (value as? String) == "complete"
        }
        let readyState = dictionary["readyState"] as? String
        guard readyState == "complete" else {
            return false
        }
        if let md2jpegReady = dictionary["md2jpegReady"] as? Bool {
            return md2jpegReady
        }
        return true
    }

    @MainActor
    private func evaluateJavaScript(_ script: String, in webView: WKWebView) async throws -> Any? {
        try await withCheckedThrowingContinuation { continuation in
            webView.evaluateJavaScript(script) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: result)
            }
        }
    }

    @MainActor
    private func measuredDocumentSize(in webView: WKWebView) async -> CGSize {
        do {
            let value = try await evaluateJavaScript(
                """
                (function() {
                  var body = document.body;
                  var doc = document.documentElement;
                  if (!body || !doc) { return null; }
                  var width = Math.max(
                    body.scrollWidth, body.offsetWidth,
                    doc.clientWidth, doc.scrollWidth, doc.offsetWidth
                  );
                  var height = Math.max(
                    body.scrollHeight, body.offsetHeight,
                    doc.clientHeight, doc.scrollHeight, doc.offsetHeight
                  );
                  return { width: width, height: height };
                })();
                """,
                in: webView
            )
            if
                let dictionary = value as? [String: Any],
                let width = dictionary["width"] as? NSNumber,
                let height = dictionary["height"] as? NSNumber
            {
                return CGSize(width: CGFloat(width.doubleValue), height: CGFloat(height.doubleValue))
            }
        } catch {
            // Fallback to UIScrollView measurement when JS probing fails.
        }
        return webView.scrollView.contentSize
    }

    private func validateCapturedTile(_ image: UIImage, expectedTileSize: CGSize, scale: CGFloat) throws {
        let expectedHeight = expectedTileSize.height * scale
        let expectedWidth = expectedTileSize.width * scale
        let actualSize = image.size
        let heightDelta = abs(actualSize.height - expectedHeight)
        let widthDelta = abs(actualSize.width - expectedWidth)
        guard heightDelta <= max(4, expectedHeight * 0.1), widthDelta <= max(4, expectedWidth * 0.1) else {
            throw ExportError.incompleteTileCapture
        }
    }

    func validateCoverage(capturedTiles: [(rect: CGRect, image: UIImage)], targetSize: CGSize) -> Bool {
        guard !capturedTiles.isEmpty else { return false }
        let sortedRects = capturedTiles.map(\.rect).sorted { $0.minY < $1.minY }
        guard let first = sortedRects.first else { return false }

        var coveredMaxY = first.maxY
        let topCovered = first.minY <= sizeTolerance
        for rect in sortedRects.dropFirst() {
            let contiguous = rect.minY <= coveredMaxY + sizeTolerance
            guard contiguous else { return false }
            coveredMaxY = max(coveredMaxY, rect.maxY)
        }

        let bottomCovered = abs(coveredMaxY - targetSize.height) <= max(sizeTolerance, targetSize.height * 0.01)
        return topCovered && bottomCovered
    }

    @MainActor
    private func snapshotTile(from webView: WKWebView, configuration: WKSnapshotConfiguration) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            webView.takeSnapshot(with: configuration) { image, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let image else {
                    continuation.resume(throwing: ExportError.snapshotFailed)
                    return
                }
                continuation.resume(returning: image)
            }
        }
    }
}
