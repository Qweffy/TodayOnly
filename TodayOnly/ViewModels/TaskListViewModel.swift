import Foundation
import SwiftData

@Observable
final class TaskListViewModel {

    func addTask(title: String, category: TaskCategory, status: TaskStatus = .pending, context: ModelContext) {
        let task = TodoTask(title: title, category: category, status: status)
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

    func rolloverTasks(from allTasks: [TodoTask]) -> [TodoTask] {
        let todayStart = startOfToday()
        return allTasks.filter { $0.status == .pending && $0.createdAt < todayStart }
    }
}
