import SwiftUI
import SwiftData

@main
struct md2jpegApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .tint(Color("AccentColor"))
        }
        .modelContainer(for: HistoryEntry.self)
    }
}
