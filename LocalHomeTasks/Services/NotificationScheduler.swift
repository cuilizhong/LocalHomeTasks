import Foundation
import UserNotifications

protocol NotificationScheduling {
    func requestAuthorizationIfNeeded() async throws -> Bool
    func scheduleReminder(for task: MaintenanceTask, remindersEnabled: Bool) async throws
    func cancelReminder(for taskID: UUID)
}

struct NotificationScheduler: NotificationScheduling {
    private let center: UNUserNotificationCenter
    private let calendar: Calendar

    init(center: UNUserNotificationCenter = .current(), calendar: Calendar = .current) {
        self.center = center
        self.calendar = calendar
    }

    func requestAuthorizationIfNeeded() async throws -> Bool {
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        @unknown default:
            return false
        }
    }

    func scheduleReminder(for task: MaintenanceTask, remindersEnabled: Bool) async throws {
        cancelReminder(for: task.id)

        guard remindersEnabled, task.reminderEnabled else { return }
        guard try await requestAuthorizationIfNeeded() else { return }

        let reminderDate = calendar.date(
            byAdding: .day,
            value: -max(task.reminderLeadDays, 0),
            to: task.nextDueDate
        ) ?? task.nextDueDate

        guard reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Home maintenance due soon"
        content.body = "\(task.title) is due on \(task.nextDueDate.formatted(date: .abbreviated, time: .omitted))."
        content.sound = .default

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.identifier(for: task.id),
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    func cancelReminder(for taskID: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier(for: taskID)])
    }

    static func identifier(for taskID: UUID) -> String {
        "maintenance-task-\(taskID.uuidString)"
    }
}
