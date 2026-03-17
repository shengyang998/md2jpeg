import SwiftUI
import UIKit

struct ExportShareSheet: UIViewControllerRepresentable {
    let fileURL: URL
    let onComplete: (Bool, Error?) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, error in
            onComplete(completed, error)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
