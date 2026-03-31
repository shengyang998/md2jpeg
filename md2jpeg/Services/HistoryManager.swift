import Foundation
import SwiftData

@MainActor
final class HistoryManager {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(markdownText: String, themeName: String) {
        guard !markdownText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Deduplicate: skip if the most recent entry has identical content
        var descriptor = FetchDescriptor<HistoryEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        descriptor.fetchLimit = 1
        if let latest = try? modelContext.fetch(descriptor).first,
           latest.markdownText == markdownText {
            return
        }

        let title = Self.extractTitle(from: markdownText)
        let entry = HistoryEntry(title: title, markdownText: markdownText, themeName: themeName)
        modelContext.insert(entry)
        try? modelContext.save()
    }

    func delete(_ entry: HistoryEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }

    static func extractTitle(from markdown: String) -> String {
        let lines = markdown.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            // Strip leading # characters for headings
            let stripped = trimmed.drop(while: { $0 == "#" })
                .trimmingCharacters(in: .whitespaces)
            if !stripped.isEmpty {
                return String(stripped.prefix(80))
            }
        }
        return "Untitled"
    }
}
