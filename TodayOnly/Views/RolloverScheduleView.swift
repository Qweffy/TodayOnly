import SwiftUI

struct RolloverScheduleView: View {
    @AppStorage(RolloverSchedule.storageKey) private var activeDaysMask = RolloverSchedule.defaultMask

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Review days")
                .font(.headline)

            Text("Days the app asks you to review unfinished tasks. Off by default on weekends.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(RolloverSchedule.allWeekdays, id: \.weekday) { day in
                    Toggle(day.label, isOn: Binding(
                        get: { RolloverSchedule.isActive(day.weekday, in: activeDaysMask) },
                        set: { activeDaysMask = RolloverSchedule.setting(day.weekday, to: $0, in: activeDaysMask) }
                    ))
                    .toggleStyle(.checkbox)
                }
            }
        }
        .padding()
        .frame(width: 240)
    }
}
