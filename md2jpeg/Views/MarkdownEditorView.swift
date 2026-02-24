import SwiftUI

struct MarkdownEditorView: View {
    @Binding var text: String
    var bottomContentInset: CGFloat = 0

    var body: some View {
        InsetTextView(text: $text, bottomContentInset: bottomContentInset)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
    }
}

private struct InsetTextView: UIViewRepresentable {
    @Binding var text: String
    let bottomContentInset: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
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
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8 + bottomContentInset, right: 8)
        textView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8 + bottomContentInset, right: 0)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding private var text: String

        init(text: Binding<String>) {
            self._text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
        }
    }
}
