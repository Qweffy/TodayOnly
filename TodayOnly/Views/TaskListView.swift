import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var todayTasks: [TodoTask]
    @State private var showingAddSheet = false

    private let viewModel = TaskListViewModel()

    init() {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        _todayTasks = Query(
            filter: #Predicate<TodoTask> { task in
                task.createdAt >= start && task.createdAt < end
            },
            sort: \TodoTask.createdAt
        )
    }

    private var mustDoTasks: [TodoTask] {
        todayTasks.filter { $0.category == .mustDo }
    }

    private var bonusTasks: [TodoTask] {
        todayTasks.filter { $0.category == .bonus }
    }

    var body: some View {
        NavigationStack {
            Group {
                if todayTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTaskView(
                    onAdd: { title, category, status in
                        viewModel.addTask(
                            title: title,
                            category: category,
                            status: status,
                            context: modelContext
                        )
                        showingAddSheet = false
                    },
                    onCancel: {
                        showingAddSheet = false
                    }
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Nothing for today")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Tap + to add a task")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var taskList: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !mustDoTasks.isEmpty {
                    sectionCard(
                        title: "Must Do",
                        icon: "flame.fill",
                        tint: .orange,
                        tasks: mustDoTasks
                    )
                }

                if !bonusTasks.isEmpty {
                    sectionCard(
                        title: "Bonus",
                        icon: "star.fill",
                        tint: .blue,
                        tasks: bonusTasks
                    )
                }
            }
            .padding()
        }
    }

    private func sectionCard(
        title: String,
        icon: String,
        tint: Color,
        tasks: [TodoTask]
    ) -> some View {
        let pending = tasks.filter { $0.status != .done }
        let done = tasks.filter { $0.status == .done }

        return VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(tint)
                Spacer()
                Text("\(pending.count) left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()
                .padding(.horizontal, 16)

            // Pending tasks
            ForEach(pending) { task in
                TaskRowView(
                    task: task,
                    onToggleDone: { viewModel.toggleDone(task) },
                    onDelete: { viewModel.delete(task, context: modelContext) }
                )
                .padding(.horizontal, 16)
            }

            // Done tasks (dimmed)
            if !done.isEmpty {
                ForEach(done) { task in
                    TaskRowView(
                        task: task,
                        onToggleDone: { viewModel.toggleDone(task) },
                        onDelete: { viewModel.delete(task, context: modelContext) }
                    )
                    .padding(.horizontal, 16)
                    .opacity(0.6)
                }
            }
        }
        .padding(.bottom, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(done.count == tasks.count
                      ? Color.green.opacity(0.08)
                      : tint.opacity(0.1))
        )
    }
}
