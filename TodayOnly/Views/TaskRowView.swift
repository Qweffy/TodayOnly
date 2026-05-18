import SwiftUI

struct TaskRowView: View {
    let task: TodoTask
    let onToggleDone: () -> Void
    let onDelete: () -> Void

    private var checkmarkColor: Color {
        if task.status == .done { return .green }
        return task.category == .mustDo ? .orange : .blue
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggleDone) {
                Image(systemName: task.status == .done ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(checkmarkColor)
            }
            .buttonStyle(.plain)

            Text(task.title)
                .strikethrough(task.status == .done)
                .foregroundStyle(task.status == .done ? .secondary : .primary)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .opacity(0.5)
        }
        .padding(.vertical, 4)
    }
}
