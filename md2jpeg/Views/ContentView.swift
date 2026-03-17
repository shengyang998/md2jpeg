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
    @Environment(\.colorScheme) private var colorScheme

    @State private var isExportSharePresented = false
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

    private var controlOverlayColors: OverlayColors {
        if appState.isRawMode {
            return .controlChrome(isDarkBackground: colorScheme == .dark)
        } else {
            return .controlChrome(isDarkBackground: appState.selectedTheme.isDarkAppearance)
        }
    }

    private var statusOverlayColors: OverlayColors {
        .statusSurface(for: colorScheme)
    }

    var body: some View {
        ZStack {
            contentLayer
            controlsOverlay
                .environment(\.overlayColors, controlOverlayColors)
            StatusOverlayHost(
                toastMessage: $appState.exportInfoMessage,
                isBlocking: appState.isExporting,
                bottomInset: bottomBarHeight
            ) {
                ExportProgressOverlay(progress: appState.exportProgress)
            }
            .environment(\.overlayColors, statusOverlayColors)
        }
        .alert("Export Error", isPresented: .constant(appState.exportErrorMessage != nil)) {
            Button("OK") { appState.exportErrorMessage = nil }
        } message: {
            Text(appState.exportErrorMessage ?? "")
        }
        .sheet(isPresented: $isExportSharePresented, onDismiss: clearExportShareState) {
            if let exportedFileURL = appState.exportedFileURL {
                ExportShareSheet(fileURL: exportedFileURL, onComplete: handleExportShareCompletion)
            }
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
            .environment(\.overlayColors, statusOverlayColors)
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
        return VStack {
            TopControlBar(
                showTitle: showTitle,
                onPaste: {
                    if let text = UIPasteboard.general.string {
                        appState.markdownText = text
                    }
                },
                onDeleteAll: {
                    appState.markdownText = ""
                },
                isDeleteDisabled: appState.markdownText.isEmpty
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: TopBarHeightKey.self, value: geo.size.height)
                }
            )

            Spacer()

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
        appState.exportedFileURL = nil

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

#if targetEnvironment(macCatalyst)
            presentExportShare(for: result, requestedFormat: format)
#else
            try await photoLibrarySaver.saveImage(at: result.fileURL)
            appState.exportProgress = 1

            if result.formatUsed != format {
                appState.exportInfoMessage = "Saved to Photos as JPEG because HEIC is unavailable on this runtime."
            } else {
                appState.exportInfoMessage = "Saved to Photos."
            }
#endif
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

    private func presentExportShare(
        for result: (fileURL: URL, formatUsed: ExportFormat),
        requestedFormat: ExportFormat
    ) {
        appState.exportedFileURL = result.fileURL
        appState.exportProgress = 1
        if result.formatUsed != requestedFormat {
            appState.exportInfoMessage = "Export ready to share as JPEG because HEIC is unavailable on this runtime."
        } else {
            appState.exportInfoMessage = "Export ready to share."
        }
        isExportSharePresented = true
    }

    private func handleExportShareCompletion(completed: Bool, error: Error?) {
        if let error {
            appState.exportErrorMessage = error.localizedDescription
            return
        }

        if completed {
            appState.exportInfoMessage = "Share completed."
        }
    }

    private func clearExportShareState() {
        appState.exportedFileURL = nil
    }

    private func refreshRenderedHTML() {
        renderedHTML = renderer.render(markdown: appState.markdownText, theme: appState.selectedTheme)
    }
}
