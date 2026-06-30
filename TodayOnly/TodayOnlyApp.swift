import SwiftUI
import SwiftData

@main
struct TodayOnlyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(macOS)
                .frame(minWidth: 400, minHeight: 500)
                #endif
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: TodoTask.self)
        #if os(macOS)
        .defaultSize(width: 480, height: 600)
        #endif
    }
}
