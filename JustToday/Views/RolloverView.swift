import SwiftUI

struct RolloverView: View {
    let tasks: [TodoTask]
    let onCarry: (TodoTask) -> Void
    let onCarryAll: () -> Void
    let onDrop: (TodoTask) -> Void
    let onMarkDone: (TodoTask) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Unfinished from yesterday")
                .font(.title2)
                .fontWeight(.semibold)

            Text("What do you want to do with these?")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if tasks.isEmpty {
                Text("All caught up!")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                List(tasks) { task in
                    HStack {
                        Text(task.title)
                            .lineLimit(1)

                        Spacer()

                        HStack(spacing: 8) {
                            Button("Carry") {
                                onCarry(task)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)

                            Button("Done") {
                                onMarkDone(task)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)

                            Button("Drop") {
                                onDrop(task)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            if !tasks.isEmpty {
                Button("Carry all to today") {
                    onCarryAll()
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Done Reviewing") {
                onDismiss()
            }
            .keyboardShortcut(.defaultAction)
            .disabled(!tasks.isEmpty)
        }
        .padding(24)
        .frame(minWidth: 500, minHeight: 300)
    }
}
