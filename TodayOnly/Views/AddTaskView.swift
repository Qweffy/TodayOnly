import SwiftUI

struct AddTaskView: View {
    let onAdd: (String, TaskCategory, TaskStatus) -> Void
    let onCancel: () -> Void

    @State private var step: AddStep = .title
    @State private var title = ""

    private enum AddStep {
        case title
        case doItNow
        case category
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, 16)
            .padding(.top, 12)

            Group {
                switch step {
                case .title:
                    titleStep
                case .doItNow:
                    doItNowStep
                case .category:
                    categoryStep
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .padding(.top, 4)
        }
        .frame(width: 320)
    }

    // MARK: - Title + Duration Question

    private var titleStep: some View {
        VStack(spacing: 16) {
            Text("New Task")
                .font(.headline)

            TextField("What do you need to do?", text: $title)
                .textFieldStyle(.roundedBorder)

            if !title.trimmingCharacters(in: .whitespaces).isEmpty {
                VStack(spacing: 10) {
                    Button {
                        step = .doItNow
                    } label: {
                        Label("Less than 5 min", systemImage: "hare")
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.regular)
                    .buttonStyle(.borderedProminent)
                    .tint(.orange.opacity(0.8))

                    Button {
                        step = .category
                    } label: {
                        Label("More than 5 min", systemImage: "clock")
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    // MARK: - "Do it now" Screen

    private var doItNowStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 28))
                .foregroundStyle(.orange)

            Text("Do it now.")
                .font(.title3)
                .fontWeight(.semibold)

            Text("\"\(title)\"")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            VStack(spacing: 8) {
                Button {
                    onAdd(title, .mustDo, .done)
                } label: {
                    Label("Already done", systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.regular)
                .buttonStyle(.borderedProminent)
                .tint(.green.opacity(0.8))

                Button {
                    onAdd(title, .mustDo, .pending)
                } label: {
                    Label("Add to today anyway", systemImage: "plus.circle")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.regular)
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Category Selection

    private var categoryStep: some View {
        VStack(spacing: 16) {
            Text("Is this required today?")
                .font(.headline)

            Text("\"\(title)\"")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            VStack(spacing: 8) {
                Button {
                    onAdd(title, .mustDo, .pending)
                } label: {
                    Label("I have to do it today", systemImage: "flame.fill")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.regular)
                .buttonStyle(.borderedProminent)
                .tint(.orange.opacity(0.8))

                Button {
                    onAdd(title, .bonus, .pending)
                } label: {
                    Label("Bonus if I do it", systemImage: "star.fill")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.regular)
                .buttonStyle(.bordered)
            }
        }
    }
}
