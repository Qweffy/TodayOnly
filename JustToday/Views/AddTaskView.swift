import SwiftUI

struct AddTaskView: View {
    let onAdd: (String, TaskCategory, TaskStatus) -> Void
    let onCancel: () -> Void

    @State private var step: AddStep = .title
    @State private var title = ""

    private enum AddStep { case title, doItNow, category }

    private var trimmed: String { title.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(DSColor.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, DSSpacing.s4)
            .padding(.top, DSSpacing.s3)

            Group {
                switch step {
                case .title: titleStep
                case .doItNow: doItNowStep
                case .category: categoryStep
                }
            }
            .padding(.horizontal, DSSpacing.s6)
            .padding(.bottom, DSSpacing.s6)
            .padding(.top, DSSpacing.s1)
        }
        .frame(width: 320)
        .background(DSColor.surfaceElevated)
    }

    // MARK: Steps

    private var titleStep: some View {
        VStack(spacing: DSSpacing.s4) {
            Text("New Task")
                .dsText(DSFont.headline)
                .foregroundStyle(DSColor.textPrimary)

            TextField("What do you need to do?", text: $title)
                .textFieldStyle(.roundedBorder)

            if !trimmed.isEmpty {
                VStack(spacing: DSSpacing.s2 + 2) {
                    choiceButton("Less than 5 min", icon: "hare", tint: DSColor.accent) { step = .doItNow }
                    choiceButton("More than 5 min", icon: "clock", prominent: false) { step = .category }
                }
            }
        }
    }

    private var doItNowStep: some View {
        VStack(spacing: DSSpacing.s4) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 28))
                .foregroundStyle(DSColor.accent)

            Text("Do it now.")
                .dsText(DSFont.title3)
                .fontWeight(.semibold)
                .foregroundStyle(DSColor.textPrimary)

            quotedTitle

            VStack(spacing: DSSpacing.s2) {
                choiceButton("Already done", icon: "checkmark.circle", tint: DSColor.done) { onAdd(title, .mustDo, .done) }
                choiceButton("Add to today anyway", icon: "plus.circle", prominent: false) { onAdd(title, .mustDo, .pending) }
            }
        }
    }

    private var categoryStep: some View {
        VStack(spacing: DSSpacing.s4) {
            Text("Is this required today?")
                .dsText(DSFont.headline)
                .foregroundStyle(DSColor.textPrimary)

            quotedTitle

            VStack(spacing: DSSpacing.s2) {
                choiceButton("I have to do it today", icon: "flame.fill", tint: DSColor.accent) { onAdd(title, .mustDo, .pending) }
                choiceButton("Bonus if I do it", icon: "star.fill", tint: DSColor.bonus) { onAdd(title, .bonus, .pending) }
            }
        }
    }

    private var quotedTitle: some View {
        Text("\"\(title)\"")
            .dsText(DSFont.caption1)
            .foregroundStyle(DSColor.textSecondary)
            .lineLimit(2)
    }

    @ViewBuilder
    private func choiceButton(_ label: String, icon: String, tint: Color = DSColor.accent, prominent: Bool = true, action: @escaping () -> Void) -> some View {
        if prominent {
            Button(action: action) {
                Label(label, systemImage: icon).frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .tint(tint)
        } else {
            Button(action: action) {
                Label(label, systemImage: icon).frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.bordered)
        }
    }
}
