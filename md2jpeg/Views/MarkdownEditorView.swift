import SwiftUI

struct MarkdownEditorView: View {
    @Binding var text: String
    @Binding var scrollOffset: CGFloat
    var topBarHeight: CGFloat
    var bottomBarHeight: CGFloat

    var body: some View {
        InsetTextView(text: $text, scrollOffset: $scrollOffset, topBarHeight: topBarHeight, bottomBarHeight: bottomBarHeight)
            .background(.ultraThinMaterial)
    }
}

private struct InsetTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var scrollOffset: CGFloat
    var topBarHeight: CGFloat
    var bottomBarHeight: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, scrollOffset: $scrollOffset)
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        view.adjustsFontForContentSizeCategory = true
        view.font = UIFont.monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        view.text = text
        view.textContainer.lineFragmentPadding = 0
        view.keyboardDismissMode = .interactive
        applyInsets(to: view)
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        applyInsets(to: uiView)
    }

    private func applyInsets(to textView: UITextView) {
        let safeArea = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .safeAreaInsets ?? .zero

        let topInset = safeArea.top + topBarHeight
        let bottomInset = safeArea.bottom + bottomBarHeight

        let newContentInset = UIEdgeInsets(top: topInset, left: 16, bottom: bottomInset, right: 16)
        if textView.textContainerInset != newContentInset {
            textView.textContainerInset = newContentInset
        }

        let newScrollInset = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        if textView.scrollIndicatorInsets != newScrollInset {
            textView.scrollIndicatorInsets = newScrollInset
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding private var text: String
        @Binding private var scrollOffset: CGFloat

        init(text: Binding<String>, scrollOffset: Binding<CGFloat>) {
            self._text = text
            self._scrollOffset = scrollOffset
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.scrollOffset = scrollView.contentOffset.y
            }
        }
    }
}
