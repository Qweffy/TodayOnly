import SwiftUI

struct RolloverView: View {
    let tasks: [TodoTask]
    let onCarry: (TodoTask) -> Void
    let onCarryAll: () -> Void
    let onDrop: (TodoTask) -> Void
    let onMarkDone: (TodoTask) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: DSSpacing.s5) {
            VStack(spacing: DSSpacing.s2) {
                Text("Unfinished from yesterday")
                    .dsText(DSFont.title2)
                    .foregroundStyle(DSColor.textPrimary)
                Text("What do you want to do with these?")
                    .dsText(DSFont.subheadline)
                    .foregroundStyle(DSColor.textSecondary)
            }

            if tasks.isEmpty {
                Text("All caught up!")
                    .dsText(DSFont.body)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding()
            } else {
                List(tasks) { task in
                    HStack {
                        Text(task.title)
                            .dsText(DSFont.body)
                            .foregroundStyle(DSColor.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        HStack(spacing: DSSpacing.s2) {
                            Button("Carry") { onCarry(task) }
                                .buttonStyle(.borderedProminent)
                                .tint(DSColor.accent)
                                .controlSize(.small)

                            Button("Done") { onMarkDone(task) }
                                .buttonStyle(.bordered)
                                .controlSize(.small)

                            Button("Drop") { onDrop(task) }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .foregroundStyle(DSColor.destructiveText)
                        }
                    }
                    .padding(.vertical, DSSpacing.s1)
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }

            if !tasks.isEmpty {
                Button("Carry all to today") { onCarryAll() }
                    .buttonStyle(.borderedProminent)
                    .tint(DSColor.accent)
            }

            Button("Done Reviewing") { onDismiss() }
                .keyboardShortcut(.defaultAction)
                .disabled(!tasks.isEmpty)
        }
        .padding(DSSpacing.s6)
        .frame(minWidth: 500, minHeight: 300)
        .background(DSColor.surfaceElevated)
    }
}
