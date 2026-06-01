import Foundation
import SwiftData

enum TaskStatus: String, Codable {
    case pending
    case done
    case dropped
}

enum TaskCategory: String, Codable {
    case mustDo
    case bonus
}

@Model
final class TodoTask {
    var id: UUID
    var title: String
    var category: TaskCategory
    var status: TaskStatus
    var createdAt: Date
    var notes: String = ""
    var sortIndex: Int = 0

    init(title: String, category: TaskCategory, status: TaskStatus = .pending, notes: String = "", sortIndex: Int = 0) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.status = status
        self.createdAt = Date()
        self.notes = notes
        self.sortIndex = sortIndex
    }
}
