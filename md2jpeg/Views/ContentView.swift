import SwiftUI
import WebKit

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    @State private var webViewRef: WKWebView?
    @State private var renderedHTML: String = ""
    @State private var isPreviewSheetPresented = false
    @State private var selectedPreviewDetent: PresentationDetent = .height(Self.collapsedPreviewBaseHeight)
    @State private var isClearConfirmationPresented = false

    private let renderer = MarkdownHTMLRenderer()
    private let exportService = ImageExportService()
    private let photoLibrarySaver = PhotoLibrarySaver()
    private static let collapsedPreviewBaseHeight: CGFloat = 72
    private static let editorInsetExtraPadding: CGFloat = 16

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                editorToolbar
                if appState.isExporting {
                    ProgressView(value: appState.exportProgress, total: 1.0)
                        .progressViewStyle(.linear)
                }
                if let exportInfoMessage = appState.exportInfoMessage, !appState.isExporting {
                    Text(exportInfoMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            appState.exportInfoMessage = nil
                        }
                }

                ThemePickerView(selectedTheme: $appState.selectedTheme)
                    .onTapGesture { dismissKeyboard() }

                MarkdownEditorView(
                    text: $appState.markdownText,
                    bottomContentInset: editorBottomInset
                )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            .navigationTitle("Markdown-IMG")
            .alert("Export Error", isPresented: .constant(appState.exportErrorMessage != nil), actions: {
                Button("OK") { appState.exportErrorMessage = nil }
            }, message: {
                Text(appState.exportErrorMessage ?? "")
            })
            .sheet(isPresented: $isPreviewSheetPresented, onDismiss: {
                // Keep preview available as a persistent bottom sheet.
                isPreviewSheetPresented = true
            }) {
                previewSheet
                    .presentationDetents([collapsedPreviewDetent, .large], selection: $selectedPreviewDetent)
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.enabled(upThrough: collapsedPreviewDetent))
                    .presentationCornerRadius(20)
                    .interactiveDismissDisabled()
            }
            .onAppear {
                refreshRenderedHTML()
                if !isPreviewSheetPresented {
                    selectedPreviewDetent = collapsedPreviewDetent
                    isPreviewSheetPresented = true
                }
            }
            .onChange(of: appState.markdownText) { _ in
                refreshRenderedHTML()
            }
            .onChange(of: appState.selectedTheme) { _ in
                refreshRenderedHTML()
            }
        }
    }

    private var editorToolbar: some View {
        HStack {
            Button("Paste") {
                appState.markdownText = UIPasteboard.general.string ?? appState.markdownText
            }
            .buttonStyle(.bordered)

            Button("Clear") {
                isClearConfirmationPresented = true
            }
            .buttonStyle(.bordered)

            Spacer()

            Picker("Format", selection: $appState.selectedFormat) {
                ForEach(ExportFormat.allCases) { format in
                    Text(format.displayName).tag(format)
                }
            }
            .pickerStyle(.menu)

            Button {
                Task { await handleExport() }
            } label: {
                if appState.isExporting {
                    ProgressView()
                } else {
                    Text("Export")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(appState.isExporting || appState.isPreviewLoading)
        }
        .onTapGesture { dismissKeyboard() }
    }

    private var previewSheet: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Capsule()
                    .fill(.secondary)
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                Text("Preview")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedPreviewDetent = .large
                dismissKeyboard()
            }

            Divider()

            MarkdownPreviewView(
                html: renderedHTML,
                isLoading: $appState.isPreviewLoading,
                errorMessage: $appState.previewErrorMessage,
                webViewRef: $webViewRef,
                onTopEdgePullDown: { distance in
                    guard selectedPreviewDetent == .large else { return }
                    guard distance >= 56 else { return }
                    selectedPreviewDetent = collapsedPreviewDetent
                }
            )
        }
        .background(.regularMaterial)
        .onTapGesture { dismissKeyboard() }
        .ignoresSafeArea(.container, edges: .top)
        .confirmationDialog(
            "Clear markdown?",
            isPresented: $isClearConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Clear All", role: .destructive) {
                appState.markdownText = ""
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove all current markdown content.")
        }
    }

    private var safeAreaBottomInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .safeAreaInsets.bottom ?? 0
    }

    private var collapsedPreviewHeight: CGFloat {
        Self.collapsedPreviewBaseHeight + safeAreaBottomInset
    }

    private var collapsedPreviewDetent: PresentationDetent {
        .height(collapsedPreviewHeight)
    }

    private var editorBottomInset: CGFloat {
        selectedPreviewDetent == .large ? 0 : collapsedPreviewHeight + Self.editorInsetExtraPadding
    }

    private func refreshRenderedHTML() {
        renderedHTML = renderer.render(markdown: appState.markdownText, theme: appState.selectedTheme)
    }

    private func handleExport() async {
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
            if !isPreviewSheetPresented {
                isPreviewSheetPresented = true
            }
        }

        do {
            let result = try await exportService.exportSingleImage(
                from: webViewRef,
                preferredFormat: appState.selectedFormat,
                htmlForBackgroundExport: renderedHTML,
                onProgress: { progress in
                    appState.exportProgress = min(max(progress, 0), 1)
                }
            )
            try await photoLibrarySaver.saveImage(at: result.fileURL)
            appState.exportProgress = 1

            if result.formatUsed != appState.selectedFormat {
                appState.exportInfoMessage = "Saved to Photos as JPEG because HEIC is unavailable on this runtime."
            } else {
                appState.exportInfoMessage = "Saved to Photos."
            }
        } catch {
            appState.exportErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
