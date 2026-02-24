import SwiftUI
import WebKit

struct MarkdownPreviewView: View {
    let html: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    @Binding var webViewRef: WKWebView?
    var onTopEdgePullDown: (CGFloat) -> Void = { _ in }

    var body: some View {
        ZStack(alignment: .top) {
            MarkdownPreviewWebView(
                html: html,
                onLoadingStateChange: { isLoading = $0 },
                onError: { errorMessage = $0 },
                onWebViewCreated: { webViewRef = $0 },
                onTopEdgePullDown: onTopEdgePullDown
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if isLoading {
                ProgressView("Rendering preview...")
                    .padding(8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.top, 12)
            }
        }
        .overlay(alignment: .bottomLeading) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(8)
            }
        }
    }
}
