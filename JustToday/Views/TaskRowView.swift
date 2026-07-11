import SwiftUI

struct TaskRowView: View {
    let task: TodoTask
    let onToggleDone: () -> Void
    let onDelete: () -> Void
    var onToggleCategory: (() -> Void)? = nil
    var onOpenDetail: (() -> Void)? = nil

    @State private var hovering = false

    private var isDone: Bool { task.status == .done }
    private var otherCategoryLabel: String {
        task.category == .mustDo ? "Move to Bonus" : "Move to Must Do"
    }
    private var otherCategoryIcon: String {
        task.category == .mustDo ? "star.fill" : "flame.fill"
    }
    private var isCarried: Bool {
        task.status == .pending && !Calendar.current.isDateInToday(task.createdAt)
    }

    #if os(macOS)
    private let checkboxGlyph: CGFloat = 17
    private let notesGlyph: CGFloat = 14
    #else
    private let checkboxGlyph: CGFloat = 22
    private let notesGlyph: CGFloat = 16
    #endif

    var body: some View {
        HStack(spacing: DSSpacing.gutter) {
            // Checkbox — neutral ring when pending, green filled check when done
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { onToggleDone() }
            } label: {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: checkboxGlyph))
                    .foregroundStyle(isDone ? DSColor.done : DSColor.textTertiary)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: DSSpacing.hitTarget, height: DSSpacing.hitTarget)
            }
            .buttonStyle(.plain)

            if !task.notes.isEmpty {
                Image(systemName: "note.text")
                    .font(.system(size: notesGlyph))
                    .foregroundStyle(DSColor.textTertiary)
            }

            if isCarried {
                Image(systemName: "arrow.turn.up.left")
                    .font(.system(size: notesGlyph - 2))
                    .foregroundStyle(DSColor.textQuaternary)
            }

            Text(task.title)
                .dsText(DSFont.body)
                .foregroundStyle(isDone ? DSColor.textTertiary : DSColor.textPrimary)
                .strikethrough(isDone, color: DSColor.textQuaternary)
                .lineLimit(1)

            Spacer(minLength: 0)

            // Delete — hover-reveal on macOS, subtle on iOS (context menu is the primary path)
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { onDelete() }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                    .foregroundStyle(DSColor.textSecondary)
            }
            .buttonStyle(.plain)
            .opacity(trashOpacity)
        }
        .padding(.horizontal, DSSpacing.rowPadX)
        .frame(minHeight: DSSpacing.rowMinHeight)
        .background(rowBackground)
        .contentShape(Rectangle())
        .onTapGesture { onOpenDetail?() }
        #if os(macOS)
        .onHover { hovering = $0 }
        #endif
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
                    withAnimation(.easeInOut(duration: 0.3)) { onToggleCategory() }
                } label: {
                    Label(otherCategoryLabel, systemImage: otherCategoryIcon)
                }
            }
            Button(role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) { onDelete() }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var trashOpacity: Double {
        #if os(macOS)
        hovering ? 0.7 : 0
        #else
        0.35
        #endif
    }

    private var rowBackground: Color {
        #if os(macOS)
        hovering ? DSColor.fillQuaternary : DSColor.surface
        #else
        DSColor.surface
        #endif
    }
}
