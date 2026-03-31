import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.overlayColors) private var colors

    @Query(sort: \HistoryEntry.createdAt, order: .reverse) private var entries: [HistoryEntry]

    let onRestore: (HistoryEntry) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { entry in
                    Button {
                        onRestore(entry)
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.title)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(colors.labelPrimary)
                                    .lineLimit(1)

                                Text(entry.createdAt, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(colors.labelSecondary)
                            }

                            Spacer()

                            Text(entry.themeName.capitalized)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(colors.labelSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteEntries)
            }
            .listStyle(.plain)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .overlay {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No History",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Pasted and exported content will appear here.")
                    )
                }
            }
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
        try? modelContext.save()
    }
}
