import Foundation

enum SampleTasks {
    static func make(calendar: Calendar = .current, today: Date = Date()) -> [MaintenanceTask] {
        let startOfToday = calendar.startOfDay(for: today)
        let now = Date()

        return [
            MaintenanceTask(
                title: "Replace HVAC Filter",
                notes: "Use the 16x25x1 filter from the utility closet.",
                recurrence: .monthly,
                nextDueDate: date(byAddingDays: -5, to: startOfToday, calendar: calendar),
                lastCompletedDate: date(byAddingDays: -35, to: startOfToday, calendar: calendar),
                reminderEnabled: true,
                reminderLeadDays: 3,
                createdAt: now,
                updatedAt: now
            ),
            MaintenanceTask(
                title: "Check Smoke Detectors",
                notes: "Test alarms and replace weak batteries.",
                recurrence: .monthly,
                nextDueDate: date(byAddingDays: 2, to: startOfToday, calendar: calendar),
                lastCompletedDate: date(byAddingDays: -28, to: startOfToday, calendar: calendar),
                reminderEnabled: true,
                reminderLeadDays: 1,
                createdAt: now,
                updatedAt: now
            ),
            MaintenanceTask(
                title: "Clean Dryer Vent",
                notes: "Vacuum lint from the exterior vent and hose.",
                recurrence: .monthly,
                nextDueDate: date(byAddingDays: 11, to: startOfToday, calendar: calendar),
                lastCompletedDate: nil,
                reminderEnabled: false,
                reminderLeadDays: 3,
                createdAt: now,
                updatedAt: now
            ),
            MaintenanceTask(
                title: "Service Water Heater",
                notes: "Flush tank and inspect pressure valve.",
                recurrence: .yearly,
                nextDueDate: date(byAddingDays: 35, to: startOfToday, calendar: calendar),
                lastCompletedDate: date(byAddingDays: -330, to: startOfToday, calendar: calendar),
                reminderEnabled: true,
                reminderLeadDays: 7,
                createdAt: now,
                updatedAt: now
            ),
            MaintenanceTask(
                title: "Inspect Roof Gutters",
                notes: "Clear leaves and check downspouts after heavy rain.",
                recurrence: .yearly,
                nextDueDate: date(byAddingDays: -18, to: startOfToday, calendar: calendar),
                lastCompletedDate: date(byAddingDays: -380, to: startOfToday, calendar: calendar),
                reminderEnabled: false,
                reminderLeadDays: 7,
                createdAt: now,
                updatedAt: now
            )
        ]
    }

    private static func date(byAddingDays days: Int, to date: Date, calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date
    }
}
