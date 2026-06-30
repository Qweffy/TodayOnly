import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [TodoTask]
    @State private var showRollover = false
    @State private var rolloverChecked = false
    // Forces TaskListView re-creation when day changes, refreshing the @Query date filter
    @State private var dayToken = startOfToday()
    @AppStorage(RolloverSchedule.storageKey) private var activeDaysMask = RolloverSchedule.defaultMask

    private let viewModel = TaskListViewModel()
    private let midnightTimer = Timer.publish(every: 3600, on: .main, in: .common).autoconnect()

    private var rolloverTasks: [TodoTask] {
        viewModel.rolloverTasks(from: allTasks)
    }

    var body: some View {
        TaskListView()
            .id(dayToken)
            .sheet(isPresented: $showRollover) {
                RolloverView(
                    tasks: rolloverTasks,
                    onCarry: { viewModel.carryToToday($0) },
                    onCarryAll: {
                        viewModel.carryAll(rolloverTasks)
                        showRollover = false
                    },
                    onDrop: { viewModel.drop($0) },
                    onMarkDone: { viewModel.markDone($0) },
                    onDismiss: { showRollover = false }
                )
                .interactiveDismissDisabled()
            }
            .onAppear {
                guard !rolloverChecked else { return }
                rolloverChecked = true
                if !rolloverTasks.isEmpty && RolloverSchedule.isActiveToday(mask: activeDaysMask) {
                    showRollover = true
                }
            }
            .onReceive(midnightTimer) { _ in
                let now = startOfToday()
                guard now != dayToken else { return }
                dayToken = now
                if !rolloverTasks.isEmpty && RolloverSchedule.isActiveToday(mask: activeDaysMask) {
                    showRollover = true
                }
            }
    }
}
