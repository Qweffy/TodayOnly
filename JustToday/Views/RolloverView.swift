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
                    .multilineTextAlignment(.center)
                Text("What do you want to do with these?")
                    .dsText(DSFont.subheadline)
                    .foregroundStyle(DSColor.textSecondary)
            }
            .padding(.top, DSSpacing.s2)

            if tasks.isEmpty {
                Text("All caught up!")
                    .dsText(DSFont.body)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding()
            } else {
                List(tasks) { task in
                    taskRow(task)
                        .listRowBackground(Color.clear)
                        #if os(iOS)
                        .listRowSeparator(.hidden)
                        #endif
                }
                #if os(iOS)
                .listStyle(.plain)
                #endif
                .scrollContentBackground(.hidden)
            }

            if !tasks.isEmpty {
                Button("Carry all to today") { onCarryAll() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(DSColor.accent)
            }

            Button("Done Reviewing") { onDismiss() }
                .keyboardShortcut(.defaultAction)
                .disabled(!tasks.isEmpty)
        }
        .padding(DSSpacing.s6)
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 300)
        #else
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
        .background(DSColor.surfaceElevated)
    }

    @ViewBuilder
    private func taskRow(_ task: TodoTask) -> some View {
        #if os(iOS)
        VStack(alignment: .leading, spacing: DSSpacing.s2) {
            Text(task.title)
                .dsText(DSFont.body)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(2)
            HStack(spacing: DSSpacing.s2) {
                actionButton("Carry", tint: DSColor.accent, prominent: true) { onCarry(task) }
                actionButton("Done", tint: DSColor.done, prominent: false) { onMarkDone(task) }
                actionButton("Drop", tint: DSColor.destructiveText, prominent: false) { onDrop(task) }
            }
        }
        .padding(.vertical, DSSpacing.s2)
        #else
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
        #endif
    }

    #if os(iOS)
    @ViewBuilder
    private func actionButton(_ label: String, tint: Color, prominent: Bool, action: @escaping () -> Void) -> some View {
        if prominent {
            Button(action: action) {
                Text(label).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .tint(tint)
        } else {
            Button(action: action) {
                Text(label).frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .tint(tint)
        }
    }
    #endif
}
