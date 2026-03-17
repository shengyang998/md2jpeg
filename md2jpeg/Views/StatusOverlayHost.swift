import SwiftUI

struct StatusOverlayHost<BlockingContent: View>: View {
    @Binding var toastMessage: String?

    let isBlocking: Bool
    var bottomInset: CGFloat = 0
    var autoDismissDuration: Duration = .seconds(2.5)
    @ViewBuilder let blockingContent: () -> BlockingContent

    @State private var autoDismissTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            if isBlocking {
                blockingContent()
                    .transition(.opacity)
            }

            VStack {
                Spacer()

                if let toastMessage, !isBlocking {
                    StatusToast(message: toastMessage)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .padding(.bottom, bottomInset + 12)
                }
            }
            .padding(.horizontal, 20)
        }
        .animation(.easeInOut(duration: 0.2), value: toastMessage)
        .animation(.easeInOut(duration: 0.2), value: isBlocking)
        .onChange(of: toastMessage) { _ in
            scheduleAutoDismiss()
        }
        .onDisappear {
            cancelAutoDismiss()
        }
    }

    private func scheduleAutoDismiss() {
        cancelAutoDismiss()

        guard let message = toastMessage else { return }

        autoDismissTask = Task {
            try? await Task.sleep(for: autoDismissDuration)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                if toastMessage == message {
                    toastMessage = nil
                }
            }
        }
    }

    private func cancelAutoDismiss() {
        autoDismissTask?.cancel()
        autoDismissTask = nil
    }
}
