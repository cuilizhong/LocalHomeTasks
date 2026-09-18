import Foundation

struct TaskStatusResolver {
    func status(
        for dueDate: Date,
        today: Date = Date(),
        dueSoonWindowDays: Int = 7,
        calendar: Calendar = .current
    ) -> TaskStatus {
        let dueDay = calendar.startOfDay(for: dueDate)
        let todayDay = calendar.startOfDay(for: today)
        let days = calendar.dateComponents([.day], from: todayDay, to: dueDay).day ?? 0

        if days < 0 {
            return .overdue(days: abs(days))
        }

        if days <= dueSoonWindowDays {
            return .dueSoon(daysRemaining: days)
        }

        return .upcoming(daysRemaining: days)
    }
}
