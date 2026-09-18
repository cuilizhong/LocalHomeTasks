import Foundation

struct RecurrenceCalculator {
    func nextDueDate(
        after dueDate: Date,
        recurrence: RecurrenceRule,
        calendar: Calendar = .current
    ) -> Date {
        switch recurrence {
        case .monthly:
            return nextMonthlyDueDate(after: dueDate, calendar: calendar)
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: dueDate) ?? dueDate
        }
    }

    private func nextMonthlyDueDate(after dueDate: Date, calendar: Calendar) -> Date {
        guard let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: dueDate) else {
            return dueDate
        }

        guard isLastDayOfMonth(dueDate, calendar: calendar),
              let range = calendar.range(of: .day, in: .month, for: nextMonthDate) else {
            return nextMonthDate
        }

        var components = calendar.dateComponents([.year, .month, .hour, .minute, .second], from: nextMonthDate)
        components.day = range.count
        return calendar.date(from: components) ?? nextMonthDate
    }

    private func isLastDayOfMonth(_ date: Date, calendar: Calendar) -> Bool {
        guard let range = calendar.range(of: .day, in: .month, for: date) else {
            return false
        }

        return calendar.component(.day, from: date) == range.count
    }

    func nextFutureDueDate(
        from dueDate: Date,
        recurrence: RecurrenceRule,
        completedAt: Date,
        calendar: Calendar = .current
    ) -> Date {
        var candidate = dueDate
        let completedDay = calendar.startOfDay(for: completedAt)

        while calendar.startOfDay(for: candidate) <= completedDay {
            let next = nextDueDate(after: candidate, recurrence: recurrence, calendar: calendar)
            guard next > candidate else { break }
            candidate = next
        }

        return candidate
    }
}
