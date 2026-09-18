import Foundation

struct MaintenanceTask: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var notes: String
    var recurrence: RecurrenceRule
    var nextDueDate: Date
    var lastCompletedDate: Date?
    var reminderEnabled: Bool
    var reminderLeadDays: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        recurrence: RecurrenceRule,
        nextDueDate: Date,
        lastCompletedDate: Date? = nil,
        reminderEnabled: Bool = false,
        reminderLeadDays: Int = 3,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.recurrence = recurrence
        self.nextDueDate = nextDueDate
        self.lastCompletedDate = lastCompletedDate
        self.reminderEnabled = reminderEnabled
        self.reminderLeadDays = reminderLeadDays
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
