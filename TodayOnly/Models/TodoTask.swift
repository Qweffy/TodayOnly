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

    init(title: String, category: TaskCategory, status: TaskStatus = .pending) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.status = status
        self.createdAt = Date()
    }
}
