import SwiftUI

struct TaskDetailView: View {
    let task: TodoTask
    let onSave: (String, String) -> Void
    let onCancel: () -> Void

    @State private var title: String
    @State private var notes: String

    init(task: TodoTask, onSave: @escaping (String, String) -> Void, onCancel: @escaping () -> Void) {
        self.task = task
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: task.title)
        _notes = State(initialValue: task.notes)
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s4) {
            Text("Edit task")
                .dsText(DSFont.title2)
                .foregroundStyle(DSColor.textPrimary)

            field("Title") {
                TextField("Task title", text: $title)
                    .textFieldStyle(.roundedBorder)
            }

            field("Notes") {
                TextEditor(text: $notes)
                    .font(DSFont.body.font)
                    .foregroundStyle(DSColor.textPrimary)
                    .frame(minHeight: 120)
                    .padding(DSSpacing.s1)
                    .scrollContentBackground(.hidden)
                    .background(DSColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.sm)
                            .stroke(DSColor.border)
                    )
            }

            HStack {
                Spacer()
                Button("Cancel") { onCancel() }
                    .keyboardShortcut(.cancelAction)

                Button("Save") { onSave(trimmedTitle, notes) }
                    .buttonStyle(.borderedProminent)
                    .tint(DSColor.accent)
                    .keyboardShortcut(.defaultAction)
                    .disabled(trimmedTitle.isEmpty)
            }
        }
        .padding(DSSpacing.s6)
        .frame(minWidth: 360, minHeight: 300)
        .background(DSColor.surfaceElevated)
    }

    private func field<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.s1 + 2) {
            Text(label)
                .dsText(DSFont.caption1)
                .foregroundStyle(DSColor.textSecondary)
            content()
        }
    }
}
