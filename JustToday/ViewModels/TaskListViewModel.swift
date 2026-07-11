import Foundation
import SwiftData

@Observable
final class TaskListViewModel {

    func addTask(title: String, category: TaskCategory, status: TaskStatus = .pending, context: ModelContext, existing: [TodoTask]) {
        let task = TodoTask(
            title: title,
            category: category,
            status: status,
            sortIndex: nextSortIndex(in: existing, category: category)
        )
        context.insert(task)
    }

    func markDone(_ task: TodoTask) {
        task.status = .done
    }

    func toggleDone(_ task: TodoTask) {
        task.status = task.status == .done ? .pending : .done
    }

    func drop(_ task: TodoTask) {
        task.status = .dropped
    }

    func delete(_ task: TodoTask, context: ModelContext) {
        context.delete(task)
    }

    func carryToToday(_ task: TodoTask) {
        // Move to today by updating createdAt so the date filter picks it up
        task.createdAt = Date()
        task.status = .pending
    }

    func carryAll(_ tasks: [TodoTask]) {
        for task in tasks {
            carryToToday(task)
        }
    }

    func toggleCategory(_ task: TodoTask, all: [TodoTask]) {
        let destination: TaskCategory = task.category == .mustDo ? .bonus : .mustDo
        task.sortIndex = nextSortIndex(in: all, category: destination)
        task.category = destination
    }

    func update(_ task: TodoTask, title: String, notes: String) {
        task.title = title
        task.notes = notes
    }

    /// Reorder `task` to the position of `target` within its section. Symmetric
    /// for up/down drags: remove from the source index, then insert at the
    /// target's index. Pass `newCategory` when the drop crosses sections so the
    /// task also lands at the dropped position in the destination. `ordered` is
    /// the destination section's already-sorted pending array.
    func move(_ task: TodoTask, onto target: TodoTask, into newCategory: TaskCategory? = nil, within ordered: [TodoTask]) {
        if let newCategory {
            task.category = newCategory
        }

        var section = ordered.filter { $0.category == task.category }
        guard let destIndex = section.firstIndex(where: { $0.id == target.id }) else {
            section.removeAll { $0.id == task.id }
            section.append(task)
            renumber(section)
            return
        }

        if let srcIndex = section.firstIndex(where: { $0.id == task.id }) {
            // same-section reorder: dragged item lands at the target's position
            section.remove(at: srcIndex)
            section.insert(task, at: min(destIndex, section.count))
        } else {
            // cross-section: land at the target's position
            section.insert(task, at: destIndex)
        }
        renumber(section)
    }

    /// Next free index at the end of a category's tasks.
    func nextSortIndex(in tasks: [TodoTask], category: TaskCategory) -> Int {
        (tasks.filter { $0.category == category }.map(\.sortIndex).max() ?? -1) + 1
    }

    /// Reorder a section's rows (from a List `.onMove`) and renumber their sortIndex.
    func reorder(_ ordered: [TodoTask], fromOffsets: IndexSet, toOffset: Int) {
        var arr = ordered
        arr.move(fromOffsets: fromOffsets, toOffset: toOffset)
        renumber(arr)
    }

    func rolloverTasks(from allTasks: [TodoTask]) -> [TodoTask] {
        let todayStart = startOfToday()
        return allTasks.filter { $0.status == .pending && $0.createdAt < todayStart }
    }

    private func renumber(_ tasks: [TodoTask]) {
        for (index, task) in tasks.enumerated() {
            task.sortIndex = index
        }
    }
}
