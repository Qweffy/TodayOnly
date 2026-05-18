import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [TodoTask]
    @State private var showRollover = false
    @State private var rolloverChecked = false

    private let viewModel = TaskListViewModel()

    private var rolloverTasks: [TodoTask] {
        viewModel.rolloverTasks(from: allTasks)
    }

    var body: some View {
        TaskListView()
            .sheet(isPresented: $showRollover) {
                RolloverView(
                    tasks: rolloverTasks,
                    onCarry: { viewModel.carryToToday($0) },
                    onDrop: { viewModel.drop($0) },
                    onMarkDone: { viewModel.markDone($0) },
                    onDismiss: { showRollover = false }
                )
                .interactiveDismissDisabled()
            }
            .onAppear {
                guard !rolloverChecked else { return }
                rolloverChecked = true
                if !rolloverTasks.isEmpty {
                    showRollover = true
                }
            }
    }
}
