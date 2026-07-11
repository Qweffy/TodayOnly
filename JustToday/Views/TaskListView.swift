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
                task.createdAt < end
            },
            sort: \TodoTask.createdAt
        )
    }

    private var mustDoTasks: [TodoTask] { orderedTasks(in: .mustDo) }
    private var bonusTasks: [TodoTask] { orderedTasks(in: .bonus) }

    private func orderedTasks(in category: TaskCategory) -> [TodoTask] {
        // Show tasks created today OR still-pending items carried over from earlier days.
        let today = startOfToday()
        return todayTasks
            .filter { $0.category == category && ($0.createdAt >= today || $0.status == .pending) }
            .sorted { $0.sortIndex != $1.sortIndex ? $0.sortIndex < $1.sortIndex : $0.createdAt < $1.createdAt }
    }

    #if os(macOS)
    private let headerIconSize: CGFloat = 15
    private let emptyCircle: CGFloat = 48
    private let emptySun: CGFloat = 24
    #else
    private let headerIconSize: CGFloat = 18
    private let emptyCircle: CGFloat = 60
    private let emptySun: CGFloat = 30
    #endif

    var body: some View {
        NavigationStack {
            Group {
                if todayTasks.isEmpty {
                    emptyState
                } else {
                    #if os(iOS)
                    iosList
                    #else
                    taskList
                    #endif
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
                    .foregroundStyle(DSColor.textSecondary)
                    #if os(macOS)
                    .popover(isPresented: $showingSchedule) {
                        RolloverScheduleView()
                    }
                    #endif
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .foregroundStyle(DSColor.accent)
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
                    onCancel: { showingAddSheet = false }
                )
                #if os(iOS)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                #endif
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
                    onCancel: { editingTask = nil }
                )
                #if os(iOS)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                #endif
            }
            #if os(iOS)
            .sheet(isPresented: $showingSchedule) {
                RolloverScheduleView()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            #endif
        }
        .tint(DSColor.accent)
    }

    private var emptyState: some View {
        VStack(spacing: DSSpacing.s2) {
            ZStack {
                Circle()
                    .fill(DSColor.surfaceElevated)
                    .frame(width: emptyCircle, height: emptyCircle)
                Image(systemName: "sun.max")
                    .font(.system(size: emptySun))
                    .foregroundStyle(DSColor.textTertiary)
            }
            .padding(.bottom, DSSpacing.s2)

            Text("Nothing for today")
                .font(.system(size: DSFont.title3.size, weight: .bold, design: .rounded))
                .foregroundStyle(DSColor.textPrimary)

            Text("Add the one thing that matters today.")
                .dsText(DSFont.subheadline)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
        }
        .padding(DSSpacing.s6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.bgBase)
    }

    #if os(macOS)
    private var taskList: some View {
        ScrollView {
            VStack(spacing: DSSpacing.sectionGap) {
                if !mustDoTasks.isEmpty {
                    sectionCard(title: "Must Do", icon: "flame.fill", tint: DSColor.accent, targetCategory: .mustDo, tasks: mustDoTasks)
                }
                if !bonusTasks.isEmpty {
                    sectionCard(title: "Bonus", icon: "star.fill", tint: DSColor.bonus, targetCategory: .bonus, tasks: bonusTasks)
                }
            }
            .padding(DSSpacing.screenMargin)
            .animation(.easeInOut(duration: 0.3), value: mustDoTasks.map(\.id))
            .animation(.easeInOut(duration: 0.3), value: bonusTasks.map(\.id))
        }
        .background(DSColor.bgBase)
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
        let rows = pending + done

        return VStack(spacing: 0) {
            // Header
            HStack(spacing: DSSpacing.gutter) {
                Image(systemName: icon)
                    .font(.system(size: headerIconSize))
                    .foregroundStyle(allDone ? DSColor.done : tint)
                Text(title)
                    .dsText(DSFont.title2)
                    .foregroundStyle(DSColor.textPrimary)
                Spacer()
                if allDone {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 15))
                        Text("All done")
                            .dsText(DSFont.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(DSColor.done)
                } else {
                    Text("\(pending.count) left")
                        .dsText(DSFont.subheadline)
                        .foregroundStyle(DSColor.textTertiary)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, DSSpacing.rowPadX)
            .padding(.vertical, DSSpacing.rowPadY)
            .frame(minHeight: DSSpacing.hitTarget)

            Rectangle()
                .fill(DSColor.separator)
                .frame(height: 1)
                .padding(.horizontal, DSSpacing.rowPadX)

            // Rows (pending first, done after), hairline-separated
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, task in
                if index > 0 {
                    Rectangle().fill(DSColor.separator).frame(height: 1)
                }
                if task.status != .done {
                    taskRow(task)
                        .draggable(task.id.uuidString) { dragPreview(task) }
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
                } else {
                    taskRow(task)
                }
            }
        }
        .background(sectionBackground(allDone: allDone))
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
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
        } isTargeted: { _ in }
    }

    @ViewBuilder
    private func sectionBackground(allDone: Bool) -> some View {
        ZStack {
            DSColor.surface
            if allDone { DSColor.done.opacity(0.10) }
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
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
    }

    private func dragPreview(_ task: TodoTask) -> some View {
        Text(task.title)
            .dsText(DSFont.body)
            .foregroundStyle(DSColor.textPrimary)
            .padding(.horizontal, DSSpacing.s3)
            .padding(.vertical, DSSpacing.s2)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(DSColor.surfaceElevated)
                    .dsShadow(.raised)
            )
    }
    #endif

    // MARK: - iOS native list (inset-grouped + swipe actions)
    #if os(iOS)
    private var iosList: some View {
        let pendingLeft = (mustDoTasks + bonusTasks).filter { $0.status == .pending }.count
        return List {
            if pendingLeft == 0 {
                allDoneBanner
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 16, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            iosSection("Must Do", icon: "flame.fill", tint: DSColor.accent, category: .mustDo, tasks: mustDoTasks)
            iosSection("Bonus", icon: "star.fill", tint: DSColor.bonus, category: .bonus, tasks: bonusTasks)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(DSColor.bgBase)
    }

    @ViewBuilder
    private func iosSection(_ title: String, icon: String, tint: Color, category: TaskCategory, tasks: [TodoTask]) -> some View {
        if !tasks.isEmpty {
            let pending = tasks.filter { $0.status != .done }
            let done = tasks.filter { $0.status == .done }
            let rows = pending + done
            Section {
                ForEach(rows, id: \.id) { task in
                    iosRow(task)
                }
                .onMove { from, to in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.reorder(rows, fromOffsets: from, toOffset: to)
                    }
                }
            } header: {
                iosSectionHeader(title, icon: icon, tint: tint, count: pending.count)
            }
        }
    }

    private func iosSectionHeader(_ title: String, icon: String, tint: Color, count: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(tint)
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(DSColor.textPrimary)
            Spacer()
            Text("\(count) left")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DSColor.textTertiary)
                .monospacedDigit()
        }
        .textCase(nil)
        .padding(.bottom, 2)
    }

    private func iosRow(_ task: TodoTask) -> some View {
        let isDone = task.status == .done
        let isCarried = task.status == .pending && !Calendar.current.isDateInToday(task.createdAt)
        return HStack(spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { viewModel.toggleDone(task) }
            } label: {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isDone ? DSColor.done : DSColor.textTertiary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            if isCarried {
                Image(systemName: "arrow.turn.up.left")
                    .font(.system(size: 13))
                    .foregroundStyle(DSColor.textQuaternary)
            }

            Text(task.title)
                .dsText(DSFont.body)
                .foregroundStyle(isDone ? DSColor.textTertiary : DSColor.textPrimary)
                .strikethrough(isDone, color: DSColor.textQuaternary)
                .lineLimit(1)

            Spacer(minLength: 0)

            if !task.notes.isEmpty {
                Image(systemName: "note.text")
                    .font(.system(size: 16))
                    .foregroundStyle(DSColor.textTertiary)
            }
        }
        .padding(.vertical, 2)
        .listRowBackground(DSColor.surface)
        .contentShape(Rectangle())
        .onTapGesture { editingTask = task }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                withAnimation { viewModel.toggleDone(task) }
            } label: {
                Label(isDone ? "Undo" : "Done", systemImage: isDone ? "arrow.uturn.left" : "checkmark")
            }
            .tint(DSColor.done)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation { viewModel.delete(task, context: modelContext) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .contextMenu {
            Button {
                editingTask = task
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button {
                withAnimation { viewModel.toggleCategory(task, all: todayTasks) }
            } label: {
                Label(task.category == .mustDo ? "Move to Bonus" : "Move to Must Do",
                      systemImage: task.category == .mustDo ? "star.fill" : "flame.fill")
            }
            Button(role: .destructive) {
                withAnimation { viewModel.delete(task, context: modelContext) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var allDoneBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 26))
                .foregroundStyle(DSColor.done)
            VStack(alignment: .leading, spacing: 1) {
                Text("That's everything")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DSColor.textPrimary)
                Text("Enjoy the rest of your day.")
                    .font(.system(size: 13))
                    .foregroundStyle(DSColor.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(DSColor.doneTint)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    #endif
}
