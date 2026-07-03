import SwiftUI

struct RolloverScheduleView: View {
    @AppStorage(RolloverSchedule.storageKey) private var activeDaysMask = RolloverSchedule.defaultMask

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s3) {
            Text("Review days")
                .dsText(DSFont.headline)
                .foregroundStyle(DSColor.textPrimary)

            Text("Days the app asks you to review unfinished tasks. Off by default on weekends.")
                .dsText(DSFont.caption1)
                .foregroundStyle(DSColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: DSSpacing.s1 + 2) {
                ForEach(RolloverSchedule.allWeekdays, id: \.weekday) { day in
                    Toggle(day.label, isOn: Binding(
                        get: { RolloverSchedule.isActive(day.weekday, in: activeDaysMask) },
                        set: { activeDaysMask = RolloverSchedule.setting(day.weekday, to: $0, in: activeDaysMask) }
                    ))
                    #if os(macOS)
                    .toggleStyle(.checkbox)
                    #endif
                }
            }
            .tint(DSColor.accent)
            .foregroundStyle(DSColor.textPrimary)
        }
        .padding()
        .frame(width: 240)
        .background(DSColor.surfaceElevated)
    }
}
