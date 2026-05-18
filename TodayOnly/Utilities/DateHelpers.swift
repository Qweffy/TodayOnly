import Foundation

func startOfToday() -> Date {
    Calendar.current.startOfDay(for: Date())
}

func startOfTomorrow() -> Date {
    Calendar.current.date(byAdding: .day, value: 1, to: startOfToday())!
}

func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
    Calendar.current.isDate(date1, inSameDayAs: date2)
}
