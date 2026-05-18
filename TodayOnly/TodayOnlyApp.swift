import SwiftUI
import SwiftData

@main
struct TodayOnlyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 500)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: TodoTask.self)
        .defaultSize(width: 480, height: 600)
    }
}
