import Foundation

protocol SettingsPersistence {
    func loadSettings() async throws -> ReminderSettings
    func saveSettings(_ settings: ReminderSettings) async throws
}

struct UserDefaultsSettingsPersistence: SettingsPersistence {
    private let key = "local-home-tasks-reminder-settings"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadSettings() async throws -> ReminderSettings {
        guard let data = userDefaults.data(forKey: key) else {
            return .defaultValue
        }

        let decoder = JSONDecoder()
        return try decoder.decode(ReminderSettings.self, from: data)
    }

    func saveSettings(_ settings: ReminderSettings) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(settings)
        userDefaults.set(data, forKey: key)
    }
}
