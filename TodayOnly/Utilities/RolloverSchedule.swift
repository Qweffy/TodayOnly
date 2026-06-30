import Foundation

/// Which weekdays trigger the "review unfinished tasks" rollover prompt.
/// Persisted as a bitmask in UserDefaults via `@AppStorage`. Weekday values
/// follow `Calendar`'s `.weekday` component: 1 = Sunday ... 7 = Saturday.
enum RolloverSchedule {
    static let storageKey = "activeRolloverDays"

    /// Display order Monday -> Sunday with short labels.
    static let allWeekdays: [(weekday: Int, label: String)] = [
        (2, "Mon"), (3, "Tue"), (4, "Wed"), (5, "Thu"), (6, "Fri"), (7, "Sat"), (1, "Sun")
    ]

    /// Default: Monday through Friday active (no weekend prompts).
    static let defaultMask: Int = [2, 3, 4, 5, 6].reduce(0) { $0 | (1 << $1) }

    static func isActive(_ weekday: Int, in mask: Int) -> Bool {
        mask & (1 << weekday) != 0
    }

    static func setting(_ weekday: Int, to isOn: Bool, in mask: Int) -> Int {
        isOn ? mask | (1 << weekday) : mask & ~(1 << weekday)
    }

    static func isActiveToday(mask: Int, date: Date = Date()) -> Bool {
        isActive(Calendar.current.component(.weekday, from: date), in: mask)
    }
}
