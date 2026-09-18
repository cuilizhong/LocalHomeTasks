import Foundation

struct ReminderSettings: Codable, Equatable {
    var remindersEnabled: Bool
    var defaultLeadDays: Int
    var dueSoonWindowDays: Int

    static let defaultValue = ReminderSettings(
        remindersEnabled: false,
        defaultLeadDays: 3,
        dueSoonWindowDays: 7
    )
}
