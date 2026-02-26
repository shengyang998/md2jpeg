import SwiftUI
import WebKit

private struct TopBarHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct BottomBarHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    @State private var webViewRef: WKWebView?
    @State private var renderedHTML: String = ""
    @State private var editorScrollOffset: CGFloat = 0
    @State private var previewScrollOffset: CGFloat = 0
    @State private var topBarHeight: CGFloat = 0
    @State private var bottomBarHeight: CGFloat = 0
    private let formats = ExportFormat.allCases

    private let renderer = MarkdownHTMLRenderer()
    private let exportService = ImageExportService()
    private let photoLibrarySaver = PhotoLibrarySaver()

    var body: some View {
        ZStack {
            contentLayer
            controlsOverlay
            if appState.isExporting {
                ExportProgressOverlay(progress: appState.exportProgress)
                    .transition(.opacity)
            }
        }
        .alert("Export Error", isPresented: .constant(appState.exportErrorMessage != nil)) {
            Button("OK") { appState.exportErrorMessage = nil }
        } message: {
            Text(appState.exportErrorMessage ?? "")
        }
        .onAppear {
            refreshRenderedHTML()
        }
        .onChange(of: appState.markdownText) { _ in
            refreshRenderedHTML()
        }
        .onChange(of: appState.selectedTheme) { _ in
            refreshRenderedHTML()
        }
    }

    // MARK: - Content Layer

    private var contentLayer: some View {
        ZStack {
            MarkdownPreviewView(
                html: renderedHTML,
                isLoading: $appState.isPreviewLoading,
                errorMessage: $appState.previewErrorMessage,
                webViewRef: $webViewRef,
                scrollOffset: $previewScrollOffset
            )
            .opacity(appState.isRawMode ? 0 : 1)
            .blur(radius: appState.isRawMode ? 12 : 0)

            MarkdownEditorView(text: $appState.markdownText, scrollOffset: $editorScrollOffset, topBarHeight: topBarHeight, bottomBarHeight: bottomBarHeight)
                .opacity(appState.isRawMode ? 1 : 0)
                .blur(radius: appState.isRawMode ? 0 : 12)
                .allowsHitTesting(appState.isRawMode)
        }
        .ignoresSafeArea()
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: appState.isRawMode)
    }

    // MARK: - Controls Overlay

    private var controlsOverlay: some View {
        VStack {
            HStack {
                Text("Markdown-Image")
                    .font(.caption.weight(.semibold))
                    .tracking(2)
                    .foregroundStyle(.secondary)
                    .opacity(showTitle ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: showTitle)
                Spacer()
                if appState.isRawMode {
                    GlassButton(icon: "doc.on.clipboard") {
                        if let text = UIPasteboard.general.string {
                            appState.markdownText = text
                        }
                    }

                    Menu {
                        Button("Delete All Content", role: .destructive) {
                            appState.markdownText = ""
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 44 * 0.4, weight: .medium))
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .disabled(appState.markdownText.isEmpty)
                    .opacity(appState.markdownText.isEmpty ? 0.4 : 1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: TopBarHeightKey.self, value: geo.size.height)
                }
            )
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: appState.isRawMode)

            Spacer()

            if let exportInfoMessage = appState.exportInfoMessage, !appState.isExporting {
                Text(exportInfoMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .onTapGesture {
                        appState.exportInfoMessage = nil
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .padding(.bottom, 4)
            }

            FloatingControlBar(
                isRawMode: $appState.isRawMode,
                selectedTheme: $appState.selectedTheme,
                onExport: { format in
                    Task { await handleExport(format: format) }
                }
            )
            .padding(.bottom, 8)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: BottomBarHeightKey.self, value: geo.size.height)
                }
            )
        }
        .onPreferenceChange(TopBarHeightKey.self) { topBarHeight = $0 }
        .onPreferenceChange(BottomBarHeightKey.self) { bottomBarHeight = $0 }
    }

    // MARK: - Export

    private func handleExport(format: ExportFormat) async {
        guard !appState.isPreviewLoading else {
            appState.exportErrorMessage = ExportError.previewStillRendering.errorDescription
            return
        }

        appState.isExporting = true
        appState.exportProgress = 0
        appState.exportErrorMessage = nil
        appState.exportInfoMessage = nil

        defer {
            appState.isExporting = false
        }

        do {
            let result = try await exportService.exportSingleImage(
                from: webViewRef,
                preferredFormat: format,
                htmlForBackgroundExport: renderedHTML,
                onProgress: { progress in
                    appState.exportProgress = min(max(progress, 0), 1)
                }
            )
            try await photoLibrarySaver.saveImage(at: result.fileURL)
            appState.exportProgress = 1

            if result.formatUsed != format {
                appState.exportInfoMessage = "Saved to Photos as JPEG because HEIC is unavailable on this runtime."
            } else {
                appState.exportInfoMessage = "Saved to Photos."
            }
        } catch {
            appState.exportErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    // MARK: - Helpers

    private var showTitle: Bool {
        let offset = appState.isRawMode ? editorScrollOffset : previewScrollOffset
        let threshold = topBarHeight > 0 ? topBarHeight * 0.4 : 20
        return offset < threshold
    }

    private func refreshRenderedHTML() {
        renderedHTML = renderer.render(markdown: appState.markdownText, theme: appState.selectedTheme)
    }
}
