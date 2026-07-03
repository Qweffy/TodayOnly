import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var todayTasks: [TodoTask]
    @State private var showingAddSheet = false
    @State private var draggedTask: TodoTask?
    @State private var editingTask: TodoTask?
    @State private var showingSchedule = false

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
        orderedTasks(in: .mustDo)
    }

    private var bonusTasks: [TodoTask] {
        orderedTasks(in: .bonus)
    }

    private func orderedTasks(in category: TaskCategory) -> [TodoTask] {
        todayTasks
            .filter { $0.category == category }
            .sorted { $0.sortIndex != $1.sortIndex ? $0.sortIndex < $1.sortIndex : $0.createdAt < $1.createdAt }
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
                        showingSchedule = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                    .popover(isPresented: $showingSchedule) {
                        RolloverScheduleView()
                    }
                }
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
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.addTask(
                                title: title,
                                category: category,
                                status: status,
                                context: modelContext,
                                existing: todayTasks
                            )
                        }
                        showingAddSheet = false
                    },
                    onCancel: {
                        showingAddSheet = false
                    }
                )
            }
            .sheet(item: $editingTask) { task in
                TaskDetailView(
                    task: task,
                    onSave: { newTitle, newNotes in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.update(task, title: newTitle, notes: newNotes)
                        }
                        editingTask = nil
                    },
                    onCancel: {
                        editingTask = nil
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
                        targetCategory: .mustDo,
                        tasks: mustDoTasks
                    )
                }

                if !bonusTasks.isEmpty {
                    sectionCard(
                        title: "Bonus",
                        icon: "star.fill",
                        tint: .blue,
                        targetCategory: .bonus,
                        tasks: bonusTasks
                    )
                }
            }
            .padding()
            .animation(.easeInOut(duration: 0.3), value: mustDoTasks.map(\.id))
            .animation(.easeInOut(duration: 0.3), value: bonusTasks.map(\.id))
        }
    }

    private func sectionCard(
        title: String,
        icon: String,
        tint: Color,
        targetCategory: TaskCategory,
        tasks: [TodoTask]
    ) -> some View {
        let pending = tasks.filter { $0.status != .done }
        let done = tasks.filter { $0.status == .done }
        let allDone = pending.isEmpty && !done.isEmpty

        return VStack(alignment: .leading, spacing: 0) {
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

            ForEach(pending) { task in
                taskRow(task)
                    .draggable(task.id.uuidString) {
                        dragPreview(task)
                    }
                    .dropDestination(for: String.self) { droppedIDs, _ in
                        guard let idStr = droppedIDs.first,
                              let uuid = UUID(uuidString: idStr),
                              uuid != task.id,
                              let dragged = todayTasks.first(where: { $0.id == uuid }) else {
                            return false
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if dragged.category == task.category {
                                viewModel.move(dragged, onto: task, within: pending)
                            } else {
                                viewModel.move(dragged, onto: task, into: task.category, within: pending)
                            }
                        }
                        return true
                    }
            }

            if !done.isEmpty {
                ForEach(done) { task in
                    taskRow(task)
                        .opacity(0.6)
                }
            }
        }
        .padding(.bottom, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(allDone ? Color.green.opacity(0.08) : tint.opacity(0.1))
        )
        .dropDestination(for: String.self) { droppedIDs, _ in
            guard let idStr = droppedIDs.first,
                  let uuid = UUID(uuidString: idStr),
                  let task = todayTasks.first(where: { $0.id == uuid }),
                  task.category != targetCategory else {
                return false
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                task.sortIndex = viewModel.nextSortIndex(in: todayTasks, category: targetCategory)
                task.category = targetCategory
            }
            return true
        } isTargeted: { targeted in
            // Could add visual feedback here if needed
        }
    }

    private func taskRow(_ task: TodoTask) -> some View {
        TaskRowView(
            task: task,
            onToggleDone: { viewModel.toggleDone(task) },
            onDelete: { viewModel.delete(task, context: modelContext) },
            onToggleCategory: { viewModel.toggleCategory(task, all: todayTasks) },
            onOpenDetail: { editingTask = task }
        )
        .padding(.horizontal, 16)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
    }

    private var dragPreviewBackground: Color {
        #if os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color(uiColor: .secondarySystemBackground)
        #endif
    }

    private func dragPreview(_ task: TodoTask) -> some View {
        Text(task.title)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(dragPreviewBackground)
                    .shadow(radius: 4)
            )
    }
}
