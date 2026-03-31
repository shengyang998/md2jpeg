import Foundation
import SwiftData

@Model
final class HistoryEntry {
    var id: UUID
    var title: String
    var markdownText: String
    var themeName: String
    var createdAt: Date

    init(title: String, markdownText: String, themeName: String, createdAt: Date = .now) {
        self.id = UUID()
        self.title = title
        self.markdownText = markdownText
        self.themeName = themeName
        self.createdAt = createdAt
    }
}
