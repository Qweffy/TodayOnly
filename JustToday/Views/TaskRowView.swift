import SwiftUI

struct TaskRowView: View {
    let task: TodoTask
    let onToggleDone: () -> Void
    let onDelete: () -> Void
    var onToggleCategory: (() -> Void)? = nil
    var onOpenDetail: (() -> Void)? = nil

    private var checkmarkColor: Color {
        if task.status == .done { return .green }
        return task.category == .mustDo ? .orange : .blue
    }

    private var otherCategoryLabel: String {
        task.category == .mustDo ? "Move to Bonus" : "Move to Must Do"
    }

    private var otherCategoryIcon: String {
        task.category == .mustDo ? "star.fill" : "flame.fill"
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    onToggleDone()
                }
            }) {
                Image(systemName: task.status == .done ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(checkmarkColor)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            if !task.notes.isEmpty {
                Image(systemName: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(task.title)
                .strikethrough(task.status == .done)
                .foregroundStyle(task.status == .done ? .secondary : .primary)

            Spacer()

            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onDelete()
                }
            }) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .opacity(0.5)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onOpenDetail?()
        }
        .contextMenu {
            if let onOpenDetail {
                Button {
                    onOpenDetail()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }

            if let onToggleCategory {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        onToggleCategory()
                    }
                } label: {
                    Label(otherCategoryLabel, systemImage: otherCategoryIcon)
                }
            }

            Button(role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onDelete()
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
