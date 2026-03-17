import SwiftUI
import WebKit

struct MarkdownPreviewView: View {
    let html: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    @Binding var webViewRef: WKWebView?
    @Binding var scrollOffset: CGFloat

    var body: some View {
        ZStack {
            MarkdownPreviewWebView(
                html: html,
                onLoadingStateChange: { isLoading = $0 },
                onError: { errorMessage = $0 },
                onWebViewCreated: { webViewRef = $0 },
                onScrollOffsetChange: { scrollOffset = $0 }
            )

            if isLoading {
                StatusBanner(message: "Rendering", tone: .loading)
                    .allowsHitTesting(false)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .overlay(alignment: .bottomLeading) {
            if let errorMessage {
                StatusBanner(message: errorMessage, tone: .error, lineLimit: 3)
                    .padding(12)
            }
        }
    }
}
